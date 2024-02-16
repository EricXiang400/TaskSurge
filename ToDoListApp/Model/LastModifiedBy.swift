//
//  LastModifiedBy.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 2/8/24.
//

import Foundation
import FirebaseAuth

final class LastModifiedBy: ObservableObject, Codable {
    var lastModifiedBy: String
    
    enum CodingKeys: CodingKey {
        case lastModifiedBy
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lastModifiedBy = try container.decode(String.self, forKey: .lastModifiedBy)
        self.init(lastModifiedBy: lastModifiedBy)
    }
    
    init(lastModifiedBy: String) {
        self.lastModifiedBy = lastModifiedBy
    }
    
    func changeDeviceUUID() {
        UserDefaults.standard.set(UUID().uuidString, forKey: "DeviceUUID")
        self.lastModifiedBy = UserDefaults.standard.string(forKey: "DeviceUUID")!
    }
    
    func saveData() {
        do {
            self.lastModifiedBy = UserDefaults.standard.string(forKey: "DeviceUUID")!
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let curUser = Auth.auth().currentUser {
                let fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-lastModifiedBy.json")
                let encoder = JSONEncoder()
                let encodedData = try encoder.encode(self)
                try encodedData.write(to: fileURL)
                print("lastModifiedBy saved successful")
            }
        } catch {
            fatalError("Error encoding or writing lastModifiedBy to storage")
        }
    }
    
    func loadData() {
        let data: Data
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let curUser = Auth.auth().currentUser {
                let fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-lastModifiedBy.json")
                data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let output = try decoder.decode(LastModifiedBy.self, from: data)
                self.lastModifiedBy = output.lastModifiedBy
            }
        } catch {
            fatalError("No LastModifiedBy to return")
        }
    }
}

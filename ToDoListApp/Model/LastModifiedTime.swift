//
//  LastModifiedTime.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 10/4/23.
//

import Foundation
import FirebaseAuth

final class LastModifiedTime: ObservableObject, Codable {
    var lastModifiedTime: Date
    
    enum CodingKeys: CodingKey {
        case lastModifiedTime
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lastModifiedTime = try container.decode(Date.self, forKey: .lastModifiedTime)
        self.init(lastModifiedTime: lastModifiedTime)
    }
    
    init(lastModifiedTime: Date = Date()) {
        self.lastModifiedTime = lastModifiedTime
    }
    
    func saveData() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let curUser = Auth.auth().currentUser {
                let fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-lastModifiedTime.json")
                let encoder = JSONEncoder()
                let encodedData = try encoder.encode(self)
                try encodedData.write(to: fileURL)
                print("LastModifiedTime saved successful")
            }
        } catch {
            fatalError("Error encoding or writing lastModifiedTime to storage")
        }    }
}

//
//  UserSettings.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 7/27/23.
//

import Foundation
import Firebase

final class UserSettings: NSObject, ObservableObject, Codable {
    @Published var sortOption: Int
    init(sortOption: Int = 0) {
        self.sortOption = sortOption
    }
    
    enum CodingKeys: CodingKey {
        case sortOption
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sortOption, forKey: .sortOption)
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let sortOption = try container.decode(Int.self, forKey: .sortOption)
        self.init(sortOption: sortOption)
    }
    
    static func loadLocalSettings(user: User?) -> UserSettings? {
        let data: Data
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let curUser = user {
                let fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-settings.json")
                data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(UserSettings.self, from: data)
            } else {
                let fileURL = documentDirectory.appendingPathComponent("settings.json")
                data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let output = try decoder.decode(UserSettings.self, from: data)
                print(output.sortOption)
                return output
            }
        } catch {
            print("No local settings so return nil")
            return nil
        }
    }
    
    func saveLocalSettings() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let curUser = Auth.auth().currentUser {
                let fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-settings.json")
                let encoder = JSONEncoder()
                let encodedData = try encoder.encode(self)
                try encodedData.write(to: fileURL)
                print("Settings saved successful")
            } else {
                let fileURL = documentDirectory.appendingPathComponent("settings.json")
                let encoder = JSONEncoder()
                let encodedData = try encoder.encode(self)
                try encodedData.write(to: fileURL)
                print("Settings saved successful")
            }
        } catch {
            fatalError("Error encoding or writing settings to storage")
        }
    }
    
}

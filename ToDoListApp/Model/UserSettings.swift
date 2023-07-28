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
    @Published var darkMode: Bool
    
    init(sortOption: Int = 0, darkMode: Bool = false) {
        self.sortOption = sortOption
        self.darkMode = darkMode
    }
    
    enum CodingKeys: CodingKey {
        case sortOption
        case darkMode
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sortOption, forKey: .sortOption)
        try container.encode(darkMode, forKey: .darkMode)
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let sortOption = try container.decode(Int.self, forKey: .sortOption)
        let darkMode = try container.decode(Bool.self, forKey: .darkMode)
        self.init(sortOption: sortOption, darkMode: darkMode)
    }
    
    func loadLocalSettings(user: User?) {
        let data: Data
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let curUser = user {
                let fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-settings.json")
                data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let output = try decoder.decode(UserSettings.self, from: data)
                self.sortOption = output.sortOption
                self.darkMode = output.darkMode
            } else {
                let fileURL = documentDirectory.appendingPathComponent("settings.json")
                data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let output = try decoder.decode(UserSettings.self, from: data)
                self.sortOption = output.sortOption
                self.darkMode = output.darkMode
            }
        } catch {
            print("No local settings so return nil")
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

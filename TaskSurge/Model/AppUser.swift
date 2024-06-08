//
//  User.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 6/9/23.
//

import Foundation
import Firebase

final class AppUser: ObservableObject, Codable {
    @Published var curUser: User? = Auth.auth().currentUser
    @Published var userName: String
    var uid: String
    var lastActiveDate: Date
    
    enum CodingKeys: String, CodingKey {
        case uid
        case userName
        case lastActiveDate
    }
    
    init(uid: String, userName: String, lastActiveDate: Date = Date()) {
        self.uid = uid
        self.userName = userName
        self.lastActiveDate = lastActiveDate
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uid, forKey: .uid)
        try container.encode(userName, forKey: .userName)
        try container.encode(lastActiveDate, forKey: .lastActiveDate)
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let userName = try container.decode(String.self, forKey: .userName)
        let uid = try container.decode(String.self, forKey: .uid)
        let lastActiveDate = try container.decode(Date.self, forKey: .lastActiveDate)
        self.init(uid: uid, userName: userName, lastActiveDate: lastActiveDate)
    }
    
    func saveLocalUser(user: User?, userName: String) {
        self.lastActiveDate = Date()
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let newUser = user {
                self.curUser = newUser
                self.uid = newUser.uid
                self.userName = userName
                let fileURL = documentDirectory.appendingPathComponent("\(newUser.uid)-user.json")
                let encoder = JSONEncoder()
                let encodedDate = try encoder.encode(self)
                try encodedDate.write(to: fileURL)
                print("User saved succcess")
            } else {
                let fileURL = documentDirectory.appendingPathComponent("user.json")
                let encoder = JSONEncoder()
                let encodedDate = try encoder.encode(self)
                try encodedDate.write(to: fileURL)
                print("User saved succcess")
            }
        } catch {
            print("User is nil")
        }
    }
    
    func loadLocalUser() {
        let data: Data
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let curUser = curUser {
                let fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-user.json")
                data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let output = try decoder.decode(AppUser.self, from: data)
                self.uid = output.uid
                self.userName = output.userName
                self.lastActiveDate = output.lastActiveDate
            } else {
                let fileURL = documentDirectory.appendingPathComponent("user.json")
                data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let output = try decoder.decode(AppUser.self, from: data)
                self.lastActiveDate = output.lastActiveDate
            }
        } catch {
            fatalError("User is nil")
        }
    }
    
    func initUser() {
        self.lastActiveDate = Date()
        saveLocalUser(user: nil, userName: "")
    }
    
}

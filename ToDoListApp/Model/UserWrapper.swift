//
//  UserWrapper.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 6/12/23.
//

import Foundation
import FirebaseAuth

struct UserWrapper: Codable, Hashable {
    var uid: String
    var userName: String
    
    enum CodingKeys: String, CodingKey {
        case uid
        case userName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uid = try container.decode(String.self, forKey: .uid)
        self.userName = try container.decode(String.self, forKey: .userName)
    }
    
    init(uid: String, userName: String) {
        self.uid = uid
        self.userName = userName
    }
    
    static func loadLocalUser() -> UserWrapper? {
        let data: Data
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let curUser = Auth.auth().currentUser {
                let fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-user.json")
                data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let output = try decoder.decode(UserWrapper.self, from: data)
                return output
            } else {
                print("Need to be logged in")
                return nil
            }
        } catch {
            print("user is nil")
            return nil
        }
    }
    
    static func saveLocalUser(user: User, userName: String) {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentDirectory.appendingPathComponent("\(user.uid)-user.json")
            let encoder = JSONEncoder()
            let userWrapper = UserWrapper(uid: user.uid, userName: userName)
            let encodedUser = try encoder.encode(userWrapper)
            try encodedUser.write(to: fileURL)
        } catch {
            print("User save failed")
        }
        
    }
}

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
    var uid: String
    var userName: String
    
    enum CodingKeys: String, CodingKey {
        case uid
        case userName
    }
    
    init(uid: String, userName: String) {
        self.uid = uid
        self.userName = userName
    }
    
    func saveLocalUser(user: User, userName: String) {
        self.curUser = user
        self.userName = userName
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let curUser = curUser {
                let fileURL = documentDirectory.appendingPathComponent("\(user.uid)-user.json")
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
            }
        } catch {
            print("User is nil")
        }
    }
    
}

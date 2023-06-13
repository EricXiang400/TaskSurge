//
//  UserWrapper.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 6/12/23.
//

import Foundation

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
}

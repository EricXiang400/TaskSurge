//
//  User.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 6/9/23.
//

import Foundation

struct AppUser: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
}

//
//  User.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 6/12/23.
//

import Foundation

struct User: Codable {
    var userName: String
    var todoList: [TodoContent]
}

//
//  TodoContent.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 6/1/23.
//

import Foundation

struct TodoContent: Hashable, Codable, Identifiable {
    var id: Int
    var content: String
    var completed: Bool
}

//
//  SubTaskTodoContent.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 11/6/23.
//

import Foundation

struct SubTaskTodoContent: Codable, Identifiable, Equatable {
    var id: UUID
    var content: String
    var completed: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case completed
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        completed = try container.decode(Bool.self, forKey: .completed)
    }
    
    init(content: String, completed: Bool) {
        self.id = UUID()
        self.content = content
        self.completed = completed
    }
        
}

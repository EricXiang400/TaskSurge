//
//  TodoContent.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 6/1/23.
//

import Foundation

struct TodoContent: Hashable, Codable, Identifiable {
    static var lastAssignedID: Int = 0
    var id: Int
    var content: String
    var completed: Bool
    var date: Date
    var priority: Double
    var progress: Float
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case completed
        case date
        case priority
        case progress
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        completed = try container.decode(Bool.self, forKey: .completed)
        priority = try container.decode(Double.self, forKey: .priority)
        progress = try container.decode(Float.self, forKey: .progress)
        let dateString = try container.decode(String.self, forKey: .date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        if let date = dateFormatter.date(from: dateString) {
            self.date = date
        } else {
            throw fatalError("Invalid Date Format")
        }
    }
    
    init(content: String, completed: Bool, date: Date) {
        TodoContent.lastAssignedID += 1
        id = TodoContent.lastAssignedID
        self.content = content
        self.completed = completed
        self.date = date
        self.priority = 0.0
        self.progress = 0.0
    }
}

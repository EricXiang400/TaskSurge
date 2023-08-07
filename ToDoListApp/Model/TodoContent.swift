//
//  TodoContent.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 6/1/23.
//

import Foundation

struct TodoContent: Codable, Identifiable {
    
    static var lastAssignedID: Int = 0
    var id: UUID
    var content: String
    var completed: Bool
    var date: Date
    var priority: Double
    var progress: Float
    var category: Category
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case completed
        case date
        case priority
        case progress
        case category
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        completed = try container.decode(Bool.self, forKey: .completed)
        priority = try container.decode(Double.self, forKey: .priority)
        progress = try container.decode(Float.self, forKey: .progress)
        category = try container.decode(Category.self, forKey: .category)
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
        self.id = UUID()
        self.content = content
        self.completed = completed
        self.date = date
        self.priority = 0.0
        self.progress = 0.0
        self.category = Category(name: "Untitled")
    }
    init(content: String, completed: Bool, date: Date, category: Category) {
        self.id = UUID()
        self.content = content
        self.completed = completed
        self.date = date
        self.priority = 0.0
        self.progress = 0.0
        self.category = category
    }
}

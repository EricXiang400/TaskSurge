//
//  TodoList.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 6/9/23.
//

import Foundation
import Firebase

final class TodoList: ObservableObject, Codable {
    @Published var todoList: [TodoContent]
    @Published var category: Category?
    @Published var editCategory: Category?
    
    init(todoList: [TodoContent] = [], category: Category? = nil, editCategory: Category? = nil) {
        self.todoList = todoList
        self.category = category
        self.editCategory = editCategory
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let todoList = try container.decode([TodoContent].self, forKey: .todoList)
        let category = try container.decode(Category.self, forKey: .category)
        let editCategory = try container.decode(Category.self, forKey: .editCategory)
        self.init(todoList: todoList, category: category, editCategory: editCategory)
    }
    
    enum CodingKeys: String, CodingKey {
        case todoList
        case category
        case editCategory
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(todoList, forKey: .todoList)
        try container.encode(category, forKey: .category)
        try container.encode(editCategory, forKey: .editCategory)
    }
    
    static func loadLocalData(user: User?) -> TodoList {
        let data: Data
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let curUser = user {
                let fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-data.json")
                data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(TodoList.self, from: data)
            } else {
                let fileURL = documentDirectory.appendingPathComponent("data.json")
                data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(TodoList.self, from: data)
            }
        } catch {
            print("No local Data so return []")
            return TodoList()
        }
    }

    func saveLocalData() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let curUser = Auth.auth().currentUser {
                let fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-data.json")
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let encodedData = try encoder.encode(self)
                try encodedData.write(to: fileURL)
                print("Data saved successful")
            } else {
                let fileURL = documentDirectory.appendingPathComponent("data.json")
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let encodedData = try encoder.encode(self)
                try encodedData.write(to: fileURL)
                print("Data saved successful")
            }
        } catch {
            fatalError("Error encoding or writing")
        }
    }
    
    static func loadLocalUser() -> UserWrapper? {
        let data: Data
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let curUser = Auth.auth().currentUser {
                let fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-user.json")
                data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                return try decoder.decode(UserWrapper.self, from: data)
            } else {
                print("Need to be logged in")
                return nil
            }
        } catch {
            print("user is nil")
            return nil
        }
    }
    
    static func loadLocalCategory(user: User?) -> Category? {
        let data: Data
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let curUser = user {
                let fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-category.json")
                data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                return try decoder.decode(Category.self, from: data)
            } else {
                let fileURL = documentDirectory.appendingPathComponent("category.json")
                data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                return try decoder.decode(Category.self, from: data)
            }
        } catch {
            print("No local category so return nil")
            return nil
        }
    }
    
    func saveLocalCategory() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let curUser = Auth.auth().currentUser {
                let fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-category.json")
                let encoder = JSONEncoder()
                let encodedData = try encoder.encode(category)
                try encodedData.write(to: fileURL)
                print("Category saved successful")
            } else {
                let fileURL = documentDirectory.appendingPathComponent("category.json")
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let encodedData = try encoder.encode(category)
                try encodedData.write(to: fileURL)
                print("Category saved successful")
            }
        } catch {
            fatalError("Error encoding or writing")
        }
    }
}

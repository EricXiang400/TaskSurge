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
    @Published var selectedCategory: Category?
    @Published var editCategory: Category?
    
    init(todoList: [TodoContent] = [], selectedCategory: Category? = nil, editCategory: Category? = nil) {
        self.todoList = todoList
        self.selectedCategory = selectedCategory
        self.editCategory = editCategory
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let todoList = try container.decode([TodoContent].self, forKey: .todoList)
        let selectedCategory = try container.decode(Category.self, forKey: .selectedCategory)
        let editCategory = try container.decode(Category.self, forKey: .editCategory)
        self.init(todoList: todoList, selectedCategory: selectedCategory, editCategory: editCategory)
    }
    
    enum CodingKeys: String, CodingKey {
        case todoList
        case selectedCategory
        case editCategory
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(todoList, forKey: .todoList)
        try container.encode(selectedCategory, forKey: .selectedCategory)
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
                print("GOTHERE")
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
    
    
}

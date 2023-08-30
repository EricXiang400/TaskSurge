//
//  TodoList.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 6/9/23.
//

import Foundation
import Firebase
final class TodoList: ObservableObject {
    @Published var todoList: [TodoContent] = []
    @Published var category: Category?
    @Published var editCategory: Category?

    static func loadLocalData(user: User?) -> [TodoContent] {
        let data: Data
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let curUser = user {
                let fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-data.json")
                data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode([TodoContent].self, from: data)
            } else {
                let fileURL = documentDirectory.appendingPathComponent("data.json")
                data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode([TodoContent].self, from: data)
            }
        } catch {
            print("No local Data so return []")
            return []
        }
    }

    func saveLocalData() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let curUser = Auth.auth().currentUser {
                let fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-data.json")
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let encodedData = try encoder.encode(todoList)
                try encodedData.write(to: fileURL)
                print("Data saved successful")
            } else {
                let fileURL = documentDirectory.appendingPathComponent("data.json")
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let encodedData = try encoder.encode(todoList)
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

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
    var taskSortID: Int
    
    init(todoList: [TodoContent] = [], selectedCategory: Category? = nil, editCategory: Category? = nil, taskSortID: Int = 0) {
        self.todoList = todoList
        self.selectedCategory = selectedCategory
        self.editCategory = editCategory
        self.taskSortID = taskSortID
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let todoList = try container.decode([TodoContent].self, forKey: .todoList)
        let selectedCategory = try container.decode(Category?.self, forKey: .selectedCategory)
        let editCategory = try container.decode(Category?.self, forKey: .editCategory)
        let taskSortID = try container.decode(Int.self, forKey: .taskSortID)
        self.init(todoList: todoList, selectedCategory: selectedCategory, editCategory: editCategory, taskSortID: taskSortID)
    }
    
    enum CodingKeys: String, CodingKey {
        case todoList
        case selectedCategory
        case editCategory
        case taskSortID
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(todoList, forKey: .todoList)
        try container.encode(selectedCategory, forKey: .selectedCategory)
        try container.encode(editCategory, forKey: .editCategory)
        try container.encode(taskSortID, forKey: .taskSortID)
    }
    
    func initData() {
        self.todoList = []
        self.selectedCategory = nil
        self.taskSortID = 0
        self.editCategory = nil
    }
    
    func loadLocalData(user: User?) {
        let data: Data
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let curUser = user {
                let fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-data.json")
                data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let output = try decoder.decode(TodoList.self, from: data)
                self.selectedCategory = output.selectedCategory
                self.todoList = output.todoList
                self.editCategory = output.editCategory
                self.taskSortID = output.taskSortID
            } else {
                let fileURL = documentDirectory.appendingPathComponent("data.json")
                data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let output = try decoder.decode(TodoList.self, from: data)
                self.selectedCategory = output.selectedCategory
                self.todoList = output.todoList
                self.editCategory = output.editCategory
                self.taskSortID = output.taskSortID
            }
        } catch {
            fatalError("Error loading local data")
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
}

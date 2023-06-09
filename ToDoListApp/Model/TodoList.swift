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
    
//    static func loadData() -> [TodoContent] {
//        let data: Data
//        do {
//            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//            if let curUser = Auth.auth().currentUser {
//                let fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-data.json")
//                data = try Data(contentsOf: fileURL)
//                let decoder = JSONDecoder()
//                decoder.dateDecodingStrategy = .iso8601
//                return try decoder.decode([TodoContent].self, from: data)
//            } else {
//                print("Need to be logged in")
//                return []
//            }
//        } catch {
//            return []
//        }
//    }
//    
//    static func saveData() {
//        do {
//            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//            if let curUser = Auth.auth().currentUser {
//                let fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-data.json")
//                let encoder = JSONEncoder()
//                encoder.dateEncodingStrategy = .iso8601
//                let encodedData = try encoder.encode(TodoList.todoList)
//                try encodedData.write(to: fileURL)
//                print("Data saved successful")
//            } else {
//                print("Need to log in")
//            }
//        } catch {
//            fatalError("Error encoding or writing")
//        }
//    }
}

//
//  Category.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 8/2/23.
//

import Foundation
import Firebase
final class Category: ObservableObject {
    @Published var categories: [String] = []
    
    func saveLocalCategories() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL: URL
            if let curUser = Auth.auth().currentUser {
                fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-categories.json")
            } else {
                fileURL = documentDirectory.appendingPathComponent("categories.json")
            }
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(categories)
            try encodedData.write(to: fileURL)
            print("categories saved success")
        } catch {
            print("categories saved failed")
        }
    }
    
    static func loadLocalCategories() -> [String] {
        let data: Data
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let curUser = Auth.auth().currentUser {
                let fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-categories.json")
                data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                return try decoder.decode([String].self, from: data)
            } else {
                let fileURL = documentDirectory.appendingPathComponent("categories.json")
                data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                return try decoder.decode([String].self, from: data)
            }
        } catch {
            print("No local categories to return")
            return []
        }
    }
    
}

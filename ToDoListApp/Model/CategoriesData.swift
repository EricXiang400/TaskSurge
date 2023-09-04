//
//  CategoriesData.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 8/7/23.
//

import Foundation
import Firebase


final class CategoriesData: ObservableObject, Codable {
    @Published var categories: [Category] = []
    
    enum CodingKeys: CodingKey {
        case categories
    }
    
    init(categories: [Category] = []) {
        self.categories = categories
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(categories, forKey: .categories)
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let categories = try container.decode([Category].self, forKey: .categories)
        self.init(categories: categories)
    }
    
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
            let encodedData = try encoder.encode(self)
            try encodedData.write(to: fileURL)
            print("categories saved success")
        } catch {
            print("categories saved failed")
        }
    }
    static func loadLocalCategories() -> CategoriesData {
        let data: Data
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let curUser = Auth.auth().currentUser {
                let fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-categories.json")
                data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                return try decoder.decode(CategoriesData.self, from: data)
            } else {
                let fileURL = documentDirectory.appendingPathComponent("categories.json")
                data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                return try decoder.decode(CategoriesData.self, from: data)
            }
        } catch {
            print("No local categories to return")
            return CategoriesData()
        }
    }
}

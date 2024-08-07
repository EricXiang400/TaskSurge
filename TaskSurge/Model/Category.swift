//
//  Category.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 8/2/23.
//

import Foundation
import Firebase
import SwiftUI
final class Category: ObservableObject, Codable {
    @Published var name: String
    @Published var isEditing: Bool
    var color: Color
    var id: UUID
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case color
        case isEditing
    }
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.color = Category.randomColor()
        self.isEditing = false
    }
    
    init(id: UUID, name: String, color: Color, isEditing: Bool) {
        self.id = id
        self.name = name
        self.color = color
        self.isEditing = isEditing
    }

    
    static func randomColor() -> Color {
        return Color(
            red: Double.random(in: 0.3..<1),
            green: Double.random(in: 0.3..<1),
            blue: Double.random(in: 0.3..<1)
        )
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(color, forKey: .color)
        try container.encode(isEditing, forKey: .isEditing)
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let color = try container.decode(Color.self, forKey: .color)
        let isEditing = try container.decode(Bool.self, forKey: .isEditing)
        self.init(id: id, name: name, color: color, isEditing: isEditing)
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
                let encodedData = try encoder.encode(self)
                try encodedData.write(to: fileURL)
                print("Category saved successful")
            } else {
                let fileURL = documentDirectory.appendingPathComponent("category.json")
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let encodedData = try encoder.encode(self)
                try encodedData.write(to: fileURL)
                print("Category saved successful")
            }
        } catch {
            fatalError("Error encoding or writing")
        }
    }
}

extension UIColor {
    convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
    
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let red = Int(r * 255)
        let green = Int(g * 255)
        let blue = Int(b * 255)
        let alpha = Int(a * 255)
        
        return String(format: "#%02X%02X%02X%02X", red, green, blue, alpha)
    }
    
}

extension Color: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hexString = try container.decode(String.self)

        // This part has been modified
        guard let uiColor = UIColor(hexString: hexString) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid color hex string: \(hexString)")
        }
        self.init(uiColor)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let uiColor = UIColor(self)
        let hexString = uiColor.toHexString()
        try container.encode(hexString)
    }
    
    
}

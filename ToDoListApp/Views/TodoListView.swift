//
//  TodoListView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 5/30/23.
//

import Foundation
import SwiftUI

struct TodoListView: View {
    @State private var todos: [TodoContent] = loadData(fileName: "data.json")
    
    func saveData() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentDirectory.appendingPathComponent("data.json")
            let encodedData = try JSONEncoder().encode(todos)
            try encodedData.write(to: fileURL)
            print("HERE")
        } catch {
            fatalError("Error encoding or writing")
        }
    }
    
    static func loadData(fileName: String) -> [TodoContent] {
        let data: Data
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentDirectory.appendingPathComponent("data.json")
            data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            return try decoder.decode([TodoContent].self, from: data)
        } catch {
            fatalError("Error encoding or writing")
        }
    }
    
    var body: some View {
        VStack {
            ForEach(todos) { todo in
                var todoIndex: Int {
                    $todos.firstIndex(where: {$0.id == todo.id})!
                }
                HStack(spacing: 20) {
                    SelectionButton(completed: $todos[todoIndex].completed)
                        .padding(5)
                    TextField("contefasnt", text: $todos[todoIndex].content, onCommit: saveData)
                    Spacer()
                }
            }
        }
    }
}

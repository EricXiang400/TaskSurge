//
//  TodoListView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 5/30/23.
//

import Foundation
import SwiftUI

struct TodoListView: View {
    //This line is used to reset the document directory data
//    private var t = removeDataFromDocumentDirectory(fileName: "data.json")
    @State private var todos: [TodoContent] = loadData(fileName: "data.json")
    @EnvironmentObject private var selectedDate: SelectedDate
    
    func saveData() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentDirectory.appendingPathComponent("data.json")
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let encodedData = try encoder.encode(todos)
            try encodedData.write(to: fileURL)
            print("Data saved successful")
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
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([TodoContent].self, from: data)
        } catch {
            return []
        }
    }
    
    static func removeDataFromDocumentDirectory(fileName: String) {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            try FileManager.default.removeItem(at: fileURL)
            print("File removed successfully: \(fileName)")
        } catch {
            print("Error removing file: \(error)")
        }
    }
    func sameDate(date1: Date, date2: Date) -> Bool {
        let res = Calendar.current.compare(date1, to: date2, toGranularity: .day)
        return res == .orderedSame
    }
    
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                todos.append(TodoContent(content: "", completed: false, date: selectedDate.selectedDate))
                saveData()
            } label: {
                Text("Add Task")
            }
            .padding(10)
        }
        ScrollView {
            ForEach(todos) { todo in
                var todoIndex: Int {
                    $todos.firstIndex(where: {$0.id == todo.id})!
                }
                if !sameDate(date1: selectedDate.selectedDate, date2: todo.date) {
                    HStack {}
                } else {
                    HStack(spacing: 20) {
                        SelectionButton(completed: $todos[todoIndex].completed)
                            .padding(5)
                        TextField("Empty Task", text: $todos[todoIndex].content, onCommit: saveData)
                        Spacer()
                        Button {
                            todos.remove(at: todoIndex)
                            saveData()
                        } label: {
                            Text("Finish")
                                .padding(10)
                        }
                        
                    }
                }
            }
        }
    }
}

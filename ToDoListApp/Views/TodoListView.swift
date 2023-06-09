//
//  TodoListView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 5/30/23.
//

import Foundation
import SwiftUI
import Firebase

struct TodoListView: View {
    //This line is used to reset the document directory data. just uncomment this one line
//    private var t = removeDataFromDocumentDirectory(fileName: "data.json")
    @EnvironmentObject private var todoListContainer: TodoList
    @EnvironmentObject private var selectedDateContainer: SelectedDate
    
    func saveData() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let curUser = Auth.auth().currentUser {
                let fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-data.json")
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let encodedData = try encoder.encode(todoListContainer.todoList)
                try encodedData.write(to: fileURL)
                print("Data saved successful")
            } else {
                print("Need to log in")
            }
        } catch {
            fatalError("Error encoding or writing")
        }
    }
    
    func loadData() -> [TodoContent] {
        let data: Data
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let curUser = Auth.auth().currentUser {
                let fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-data.json")
                data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode([TodoContent].self, from: data)
            } else {
                print("Need to be logged in")
                return []
            }
        } catch {
            return []
        }
    }
    
    func removeDataFromDocumentDirectory(fileName: String) {
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
                todoListContainer.todoList.append(TodoContent(content: "", completed: false, date: selectedDateContainer.selectedDate))
            } label: {
                Text("Add Task")
            }
            .padding(10)
        }
        ScrollView {
            ForEach(todoListContainer.todoList) { todo in
                var todoIndex: Int {
                    todoListContainer.todoList.firstIndex(where: {$0.id == todo.id})!
                }
                if !sameDate(date1: selectedDateContainer.selectedDate, date2: todo.date) {

                } else {
                    HStack(spacing: 20) {
                        SelectionButton(completed: $todoListContainer.todoList[todoIndex].completed)
                            .padding(5)
                        TextField("Empty Task", text: $todoListContainer.todoList[todoIndex].content, onCommit: saveData)
                        Spacer()
                        Button {
                            todoListContainer.todoList.remove(at: todoIndex)
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

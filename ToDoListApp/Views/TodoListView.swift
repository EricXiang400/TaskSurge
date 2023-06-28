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
    
    @EnvironmentObject private var todoListContainer: TodoList
    @EnvironmentObject private var selectedDateContainer: SelectedDate
    @EnvironmentObject private var curUserContainer: AppUser
    
    func sameDate(date1: Date, date2: Date) -> Bool {
        let res = Calendar.current.compare(date1, to: date2, toGranularity: .day)
        return res == .orderedSame
    }
    
    func clearDocumentDirectory() -> Bool {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: [])
            
            for fileURL in fileURLs {
                try fileManager.removeItem(at: fileURL)
                print("Removed file: \(fileURL.lastPathComponent)")
            }
            
            print("All files removed successfully.")
        } catch {
            print("Error while clearing document directory: \(error.localizedDescription)")
        }
        return true
    }
    
    func saveDataOnCommit() {
        todoListContainer.saveLocalData()
        if curUserContainer.curUser != nil {
            FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
        }
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
        List {
            ForEach(todoListContainer.todoList) { todo in
                var todoIndex: Int {
                    todoListContainer.todoList.firstIndex(where: {$0.id == todo.id})!
                }
                if sameDate(date1: selectedDateContainer.selectedDate, date2: todo.date) {
                    HStack(spacing: 20) {
                        Button {
                            todoListContainer.todoList[todoIndex].completed.toggle()
                        } label: {
                            Label("Toggle Selected", systemImage: todoListContainer.todoList[todoIndex].completed ?  "circle.fill" : "circle")
                                .labelStyle(.iconOnly)
                        }
                        .contentShape(Circle())
                        .padding(5)
                        if todoListContainer.todoList[todoIndex].completed {
                            TextField("Empty Task", text: $todoListContainer.todoList[todoIndex].content, onCommit: saveDataOnCommit)
                                .strikethrough(true)
                        } else {
                            TextField("Empty Task", text: $todoListContainer.todoList[todoIndex].content, onCommit: saveDataOnCommit)
                        }
                        
                        Spacer()
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(action: {
                            todoListContainer.todoList.remove(at: todoIndex)
                            todoListContainer.saveLocalData()
                            if curUserContainer.curUser != nil {
                                FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                            }
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                }
            }
        }
        .listStyle(.plain)
        .onAppear {
            todoListContainer.todoList = TodoList.loadLocalData(user: nil)
        }
    }
}

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
    @EnvironmentObject private var todoListContainer: TodoList
    @EnvironmentObject private var selectedDateContainer: SelectedDate
    @EnvironmentObject private var curUserContainer: AppUser
    @State var showConfirmationSheet: Bool = false
    @State var objectIndex: Int? = nil
    func sameDate(date1: Date, date2: Date) -> Bool {
        return Calendar.current.compare(date1, to: date2, toGranularity: .day) == .orderedSame
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
            Button(action:{
                todoListContainer.todoList.append(TodoContent(content: "", completed: false, date: selectedDateContainer.selectedDate))
            }) {
                Circle()
                    .foregroundColor(.blue)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 25))
                            .foregroundColor(.white)
                    )
            }
            .padding(10)
        }
        
        List {
            ForEach(todoListContainer.todoList) { todo in
                if sameDate(date1: selectedDateContainer.selectedDate, date2: todo.date) {
                    var todoIndex: Int {
                        todoListContainer.todoList.firstIndex(where: {$0.id == todo.id})!
                    }
                    HStack(spacing: 20) {
                        Button {
                            if todoListContainer.todoList[todoIndex].content != "" {
                                if todoListContainer.todoList[todoIndex].progress != 100.0 && !todoListContainer.todoList[todoIndex].completed {
                                    showConfirmationSheet = true
                                    objectIndex = todoIndex
                                } else {
                                    todoListContainer.todoList[todoIndex].completed.toggle()
                                }
                            }
                            todoListContainer.saveLocalData()
                            if curUserContainer.curUser != nil {
                                FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                            }
                        } label: {
                            Label("Toggle Selected", systemImage: todoListContainer.todoList[todoIndex].completed ?  "checkmark.circle.fill" : "circle")
                                .labelStyle(.iconOnly)
                                .foregroundColor(todoListContainer.todoList[todoIndex].completed ? Color(red: 0, green: 0.7, blue: 0) : .primary)
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
                        if todoListContainer.todoList[todoIndex].content != "" {
                            ProgressBarView(todoContent: $todoListContainer.todoList[todoIndex])
                        }
                    }
                    .sheet(isPresented: $showConfirmationSheet) {
                        ConfirmationSheetView(showConfirmationSheet: $showConfirmationSheet, listIndex: $objectIndex)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
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
            todoListContainer.todoList = TodoList.loadLocalData(user: curUserContainer.curUser)
        }
    }
}

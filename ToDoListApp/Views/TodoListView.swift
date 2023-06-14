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
    @EnvironmentObject private var curUserContainer: AppUser
    
    func sameDate(date1: Date, date2: Date) -> Bool {
        let res = Calendar.current.compare(date1, to: date2, toGranularity: .day)
        return res == .orderedSame
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
                        TextField("Empty Task", text: $todoListContainer.todoList[todoIndex].content, onCommit: saveDataOnCommit)
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
    }
}

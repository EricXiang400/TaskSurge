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
                if sameDate(date1: selectedDateContainer.selectedDate, date2: todo.date) {
                    HStack(spacing: 20) {
                        SelectionButton(completed: $todoListContainer.todoList[todoIndex].completed)
                            .padding(5)
                        TextField("Empty Task", text: $todoListContainer.todoList[todoIndex].content, onCommit: todoListContainer.saveLocalData)
                        Spacer()
                        Button {
                            todoListContainer.todoList.remove(at: todoIndex)
                            todoListContainer.saveLocalData()
                            FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
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

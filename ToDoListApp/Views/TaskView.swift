//
//  TaskView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 9/9/23.
//

import Foundation
import SwiftUI

struct TaskView: View {
    @EnvironmentObject var curUserContainer: AppUser
    @EnvironmentObject private var todoListContainer: TodoList
    @EnvironmentObject var userSettings: UserSettings
    @Binding var todoContent: TodoContent
    @State var showTaskDetails: Bool = false
    @State var todoContentCopyPassIn: TodoContent
    @State var isNewTask: Bool = false
    var body: some View {
        if todoContent.completed {
            ZStack {
                TextField("Task Name", text: $todoContent.content)
                    .disabled(true)
                    .strikethrough(true)
                Button {
                    showTaskDetails = true
                    UIApplication.shared.endEditing()
                } label: {
                    Color.clear
                }
                .sheet(isPresented: $showTaskDetails) {
                    EditTaskView(todoContentCopy: $todoContentCopyPassIn, todoContentOriginal: $todoContent, showTaskDetails: $showTaskDetails, isNewTask: $isNewTask) {
                        todoContent = todoContentCopyPassIn
                        sortTask()
                        saveData()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        } else {
            ZStack {
                TextField("Task Name", text: $todoContent.content)
                    .disabled(true)
                Button {
                    showTaskDetails = true
                    UIApplication.shared.endEditing()
                } label: {
                    Color.clear
                }
                .sheet(isPresented: $showTaskDetails) {
                    EditTaskView(todoContentCopy: $todoContentCopyPassIn, todoContentOriginal: $todoContent, showTaskDetails: $showTaskDetails, isNewTask: $isNewTask) {
                        todoContent = todoContentCopyPassIn
                        sortTask()
                        saveData()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
//    These are the same as the one in todolistview
    func saveData() {
        todoListContainer.saveLocalData()
        if curUserContainer.curUser != nil {
            FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
        }
    }
    
    func sortTask() {
        if userSettings.sortOption == 0 {
            todoListContainer.todoList.sort(by: {
                if $0.date == $1.date {
                    return $0.progress < $1.progress
                }
                return $1.date < $0.date
            })
        } else {
            todoListContainer.todoList.sort(by: {
                if $0.progress == $1.progress {
                    return $1.date < $0.date
                }
                return $0.progress < $1.progress
            })
        }
    }
}

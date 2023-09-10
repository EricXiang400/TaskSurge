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
    @State var todoContentCopyOriginVal: TodoContent
    @State var todoContentCopyPassIn: TodoContent
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
                .sheet(isPresented: $showTaskDetails, onDismiss: {
                    todoContent = todoContentCopyOriginVal
                    
                }) {
                    EditTaskView(todoContent: $todoContentCopyPassIn, showTaskDetails: $showTaskDetails) {
                        todoContent = todoContentCopyPassIn
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
                .sheet(isPresented: $showTaskDetails, onDismiss: {
                    todoContent = todoContentCopyOriginVal
                    todoContentCopyPassIn = todoContentCopyOriginVal
                }) {
                    EditTaskView(todoContent: $todoContentCopyPassIn, showTaskDetails: $showTaskDetails) {
                        todoContent = todoContentCopyPassIn
                        todoContentCopyOriginVal = todoContent
                        saveData()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    func saveData() {
        todoListContainer.saveLocalData()
        if curUserContainer.curUser != nil {
            FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
        }
    }
}

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
    @EnvironmentObject var lastModifiedTimeContainer: LastModifiedTime
    @EnvironmentObject var lastModifiedByContainer: LastModifiedBy
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
                    .opacity(0.5)
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
    
    func saveData() {
        todoListContainer.saveLocalData()
        if curUserContainer.curUser != nil {
            updateLastModifiedTimeAndBy()
            FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
        }
    }
    
    func updateLastModifiedTimeAndBy() {
        lastModifiedTimeContainer.lastModifiedTime = Date()
        lastModifiedTimeContainer.saveData()
        lastModifiedByContainer.saveData()
    }
    
    func sortTask() {
        var previousList = todoListContainer.todoList
        if userSettings.sortOption {
            todoListContainer.todoList.sort(by: {
                return $0.progress < $1.progress
            })
        } else {
            todoListContainer.todoList.sort(by: {
                return $0.taskSortID < $1.taskSortID
            })
        }
    }
}

//
//  SubTaskListView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 11/6/23.
//

import Foundation
import SwiftUI
struct SubTaskListView: View {
    @Binding var todoContent: TodoContent
    @EnvironmentObject private var todoListContainer: TodoList
    @EnvironmentObject private var lastModifiedTimeContainer: LastModifiedTime
    @EnvironmentObject private var curUserContainer: AppUser
    
    var body: some View {
        List(todoContent.subTaskList) { subTask in
            var subTaskIndex: Int {
                todoContent.subTaskList.firstIndex(where: {$0.id == subTask.id})!
            }
            HStack {
                Button(action: {
                    todoContent.subTaskList[subTaskIndex].completed.toggle()
                    saveData()
                }) {
                    Image(systemName: todoContent.subTaskList[subTaskIndex].completed ?  "checkmark.circle.fill" : "circle")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(todoContent.subTaskList[subTaskIndex].completed ? Color(red: 0, green: 0.7, blue: 0) : .primary)
                }
                .padding(5)
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    func updateLastModifiedTime() {
        lastModifiedTimeContainer.lastModifiedTime = Date()
        lastModifiedTimeContainer.saveData()
    }
    
    func saveData() {
        todoListContainer.saveLocalData()
        if curUserContainer.curUser != nil {
            updateLastModifiedTime()
            FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
        }
    }
}

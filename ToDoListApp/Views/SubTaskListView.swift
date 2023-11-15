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
    @FocusState private var focusReference: UUID?
    enum Field: Hashable {
        case details
    }
    
    var body: some View {
        HStack {
            Text("Sub-Tasks")
                .font(.title)
                .bold()
            Spacer()
            Button(action: {
                var newTask = SubTaskTodoContent(content: "", completed: false)
                todoContent.subTaskList.append(newTask)
                focusReference = newTask.id
                
            }, label: {
                Image(systemName: "plus")
            })
        }
        .padding(.horizontal)
        .padding(.vertical, 3)
        
        List(todoContent.subTaskList) { subTask in
            var subTaskIndex: Int {
                todoContent.subTaskList.firstIndex(where: {$0.id == subTask.id})!
            }
            HStack {
                Button(action: {
                    todoContent.subTaskList[subTaskIndex].completed.toggle()
                }) {
                    Image(systemName: todoContent.subTaskList[subTaskIndex].completed ?  "checkmark.circle.fill" : "circle")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(todoContent.subTaskList[subTaskIndex].completed ? Color(red: 0, green: 0.7, blue: 0) : .primary)
                }
                .padding(5)
                .buttonStyle(PlainButtonStyle())
                .disabled(todoContent.subTaskList[subTaskIndex].content == "")
                TextField("Sub-Task Details Here", text: $todoContent.subTaskList[subTaskIndex].content)
                    .focused($focusReference, equals: todoContent.subTaskList[subTaskIndex].id)
                    .padding(.vertical, 3)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: {
                    todoContent.subTaskList.remove(at: subTaskIndex)
                }) {
                    Label("Delete", systemImage: "trash")
                }
                .tint(.red)
            }
        }
        
    }
    
    func updateLastModifiedTime() {
        lastModifiedTimeContainer.lastModifiedTime = Date()
        lastModifiedTimeContainer.saveData()
    }
}

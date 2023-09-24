//
//  CircularProgressView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 9/23/23.
//

import Foundation
import SwiftUI

struct CircularProgressView: View {
    @EnvironmentObject private var todoListContainer: TodoList
    @EnvironmentObject private var selectedDateContainer: SelectedDate
    @EnvironmentObject var selectedDate: SelectedDate
    @EnvironmentObject private var curUserContainer: AppUser
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var categoryContainer: CategoriesData
    @Binding var todoContent: TodoContent
    @State var showConfirmationSheet: Bool = false
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color(red: 0.7, green: 0, blue: 0),
                    lineWidth: 3
                )
            Circle()
                .trim(from: 0, to: CGFloat(todoContent.progress / 100))
                .stroke(
                    Color(red: 0, green: 0.7, blue: 0),
                    style: StrokeStyle(
                        lineWidth: 3,
                        lineCap: .round
                        )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: todoContent.progress)
        }
        .onTapGesture {
            if !todoContent.completed {
                showConfirmationSheet = true
            }
            
        }
        .alert(isPresented: $showConfirmationSheet) {
            Alert(
                title: Text("Task Completion"),
                message: Text("Are you sure you want to complete this task?"),
                primaryButton: .default(Text("Complete")) {
                    todoContent.progress = 100.0
                    todoContent.completed = true
                    sortTask()
                    
                    todoListContainer.saveLocalData()
                    if curUserContainer.curUser != nil {
                        FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        
    }
    func sortTask() {
        if userSettings.sortOption {
            todoListContainer.todoList.sort(by: {
                if $0.progress == $1.progress {
                    return $1.date < $0.date
                }
                return $0.progress < $1.progress
            })
        }
    }
}

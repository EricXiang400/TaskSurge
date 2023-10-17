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
    @EnvironmentObject private var lastModifiedTimeContainer: LastModifiedTime

    @Binding var todoContent: TodoContent
    @State var showConfirmationSheet: Bool = false
    var body: some View {
        ZStack {
            Circle()
                .stroke(userSettings.coloredProgressBar ?
                        Color(red: 0.7, green: 0, blue: 0) : Color(red: 0.3, green: 0.3, blue: 0.3),
                    lineWidth: 3
                )
            Circle()
                .trim(from: 0, to: CGFloat(todoContent.progress / 100))
                .stroke(userSettings.coloredProgressBar ?
                        Color(red: 0, green: 0.7, blue: 0) : Color(red: 0, green: 0.4, blue: 1),
                    style: StrokeStyle(
                        lineWidth: 3,
                        lineCap: .round
                        )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: todoContent.progress)
        }
    }
    
    func sortTask() {
        var previousList = todoListContainer.todoList
        if userSettings.sortOption {
            todoListContainer.todoList.sort(by: {
                return $0.progress < $1.progress
            })
        } else {
            todoListContainer.todoList.sort(by: {
                print($0.taskSortID)
                return $0.taskSortID < $1.taskSortID
            })
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

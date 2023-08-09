//
//  ProgressBarView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 7/2/23.
//

import Foundation
import SwiftUI


struct ProgressBarView: View {
    @State private var totalProgress: Float = 100.0
    @State var presentPopOver: Bool = false
    @Binding var todoContent: TodoContent
    var body: some View {
        ProgressView(value: todoContent.progress, total: totalProgress)
            .progressViewStyle(CustomProgressViewStyle(presentPopOver: $presentPopOver, todoContent: $todoContent))
    }
}

struct CustomProgressViewStyle: ProgressViewStyle {
    @EnvironmentObject private var todoListContainer: TodoList
    @EnvironmentObject private var selectedDateContainer: SelectedDate
    @EnvironmentObject private var curUserContainer: AppUser
    @Binding var presentPopOver: Bool
    @Binding var todoContent: TodoContent
    
    func makeBody(configuration: Configuration) -> some View {
        let greenColor = Color(red: 0, green: 0.7, blue: 0)
        let redColor = Color(red: 0.7, green: 0, blue: 0)
        return ZStack {
            GeometryReader { geometry in
                VStack(spacing: 1) {
                    Spacer()
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: 75, height: 3.6)
                            .foregroundColor(redColor)
                        Rectangle()
                            .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * 75, height: 3.6)
                            .foregroundColor(greenColor)
                    }
                    Text("\(Int(todoContent.progress))% ")
                        .font(.system(size: 13))
                }
                .onTapGesture {
                    presentPopOver = true
                }
                .popover(isPresented: $presentPopOver) {
                    PopOverContent(todoContent: $todoContent, presentPopOver: $presentPopOver)
                }
            }
            .frame(width: 125)
        }
        .offset(x: 45)
    }
}

struct PopOverContent: View {
    @Binding var todoContent: TodoContent
    @EnvironmentObject private var todoListContainer: TodoList
    @EnvironmentObject private var selectedDateContainer: SelectedDate
    @EnvironmentObject private var curUserContainer: AppUser
    @EnvironmentObject private var userSettings: UserSettings
    @Binding var presentPopOver: Bool
    @State var progressAmount: Double = 0
    var body: some View {
        VStack {
            Text("\(Int(todoContent.progress))%")
                .bold()
            Slider(value: $todoContent.progress, in: 0...100)
                .padding([.leading, .trailing], 20)
        }
            .padding()
        HStack {
            Spacer()
            Button(action: {
                todoContent.progress = 0
                todoContent.completed = false
                sortTask()
                presentPopOver = false
                todoListContainer.saveLocalData()
                if curUserContainer.curUser != nil {
                    FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                }
            }) {
                Text("Reset Progress")
                    .font(.headline)
                    .foregroundColor(.red)
                    .frame(maxWidth: 135)
                    .padding(.vertical, 12)
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(8)
            }
            Button(action: {
                todoContent.progress = 100
                todoContent.completed = true
                sortTask()
                presentPopOver = false
                todoListContainer.saveLocalData()
                if curUserContainer.curUser != nil {
                    FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                }
            }) {
                Text("Complete Task")
                    .font(.headline)
                    .foregroundColor(.green)
                    .frame(maxWidth: 135)
                    .padding(.vertical, 12)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
            }
            .padding(.leading)
            Spacer()
        }
        
    }
    private func updateProgress(increment: Float) {
        let newProgress = todoContent.progress + increment
        todoContent.progress = max(min(newProgress, 100), 0)
        todoListContainer.saveLocalData()
        if curUserContainer.curUser != nil {
            FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
        }
    }
    
    func sortTask() {
        if userSettings.sortOption == 0 {
            todoListContainer.todoList.sort(by: {$1.date < $0.date})
        } else {
            todoListContainer.todoList.sort(by: {$0.progress < $1.progress})
        }
    }
}

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
    @Binding var selectedTodoContent: TodoContent
    @Binding var showProgressEditView: Bool
    var body: some View {
        ProgressView(value: todoContent.progress, total: totalProgress)
            .progressViewStyle(CustomProgressViewStyle(presentPopOver: $presentPopOver, todoContent: $todoContent, selectedTodoContent: $selectedTodoContent, showProgressEditView: $showProgressEditView))
    }
}

struct CustomProgressViewStyle: ProgressViewStyle {
    @EnvironmentObject private var todoListContainer: TodoList
    @EnvironmentObject private var selectedDateContainer: SelectedDate
    @EnvironmentObject private var curUserContainer: AppUser
    @EnvironmentObject private var userSettings: UserSettings
    @Binding var presentPopOver: Bool
    @Binding var todoContent: TodoContent
    @Binding var selectedTodoContent: TodoContent
    @Binding var showProgressEditView: Bool
    @State var slideBarAmount: Float = 0
    
    func makeBody(configuration: Configuration) -> some View {
        return ZStack {
            GeometryReader { geometry in
                VStack(spacing: 1) {
                    Spacer()
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: 75, height: 3.6)
                            .foregroundColor(userSettings.coloredProgressBar ?
                                             Color(red: 0.7, green: 0, blue: 0) : Color(red: 0.3, green: 0.3, blue: 0.3))
                            .cornerRadius(25)
                        Rectangle()
                            .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * 75, height: 3.6)
                            .foregroundColor(userSettings.coloredProgressBar ?
                                             Color(red: 0, green: 0.7, blue: 0) : Color(red: 0, green: 0.4, blue: 1))
                            .animation(.easeInOut, value: todoContent.progress)
                            .cornerRadius(25)
                    }
                    Text("\(Int(todoContent.progress))% ")
                        .font(.system(size: 13))
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showProgressEditView = true
                    }
                    selectedTodoContent = todoContent
                }
                .sheet(isPresented: $presentPopOver) {
                    PopOverContent(todoContent: $todoContent, presentPopOver: $presentPopOver, slideBarAmount: $slideBarAmount)
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
    @Binding var slideBarAmount: Float
    @EnvironmentObject private var lastModifiedTimeContainer: LastModifiedTime
    @EnvironmentObject private var lastModifiedByContainer: LastModifiedBy
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        presentPopOver = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .padding()
            }
            VStack {
                Text("\(Int(slideBarAmount))%")
                    .font(.system(size: 25))
                    .bold()
                    .padding()
                Slider(value: $slideBarAmount, in: 0...100)
                    .padding([.leading, .trailing], 20)
            }
            .padding()
            .onAppear {
                slideBarAmount = todoContent.progress
            }
            HStack {
                Spacer()
                Button(action: {
                    guard let index = todoListContainer.todoList.firstIndex(where: {todoContent.id == $0.id}) else {
                        print("Could not find todocontent index")
                        return
                    }
                    todoListContainer.todoList[index].progress = 0
                    todoListContainer.todoList[index].completed = false
                    if userSettings.sortOption {
                        sortTask()
                    }
                    
                    withAnimation(.easeInOut(duration: 0.25)) {
                        presentPopOver = false
                    }
                    todoListContainer.saveLocalData()
                    updateLastModifiedTimeAndBy()
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
                Button  {
                    guard let index = todoListContainer.todoList.firstIndex(where: {todoContent.id == $0.id}) else {
                        print("Could not find todocontent index")
                        return
                    }
                    todoListContainer.todoList[index].progress = slideBarAmount
                    if todoListContainer.todoList[index].progress != 100 {
                        todoListContainer.todoList[index].completed = false
                    } else {
                        todoListContainer.todoList[index].completed = true
                    }
                    sortTask()
                    withAnimation(.easeInOut(duration: 0.25)) {
                        presentPopOver = false
                    }
                    todoListContainer.saveLocalData()
                    updateLastModifiedTimeAndBy()
                    if curUserContainer.curUser != nil {
                        FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                    }
                } label: {
                    Text("Confirm")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: 135)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding(.leading)
                Spacer()
            }
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
    
    func updateLastModifiedTimeAndBy() {
        lastModifiedTimeContainer.lastModifiedTime = Date()
        lastModifiedTimeContainer.saveData()
        lastModifiedByContainer.saveData()
    }
}
//
//  EditTaskView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 9/8/23.
//

import Foundation
import Firebase
import SwiftUI

struct EditTaskView: View {
    @EnvironmentObject private var todoListContainer: TodoList
    @EnvironmentObject private var selectedDateContainer: SelectedDate
    @EnvironmentObject private var curUserContainer: AppUser
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var categoryContainer: CategoriesData
    @Binding var todoContentCopy: TodoContent
    @Binding var todoContentOriginal: TodoContent
    @Binding var showTaskDetails: Bool
    @Binding var isNewTask: Bool
    @FocusState private var focusField: Field?
    var confirmClosure: () -> Void
    
    enum Field: Hashable {
        case details
    }

    var body: some View {
        VStack {
            HStack {
                if isNewTask {
                    Text("New Task")
                        .font(.title)
                        .bold()
                        .padding()
                } else {
                    Text("Edit Task")
                        .font(.title)
                        .bold()
                        .padding()
                }
                Spacer()
            }
            TextEditor(text: $todoContentCopy.content)
                .frame(height: 200)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                .padding()
                .focused($focusField, equals: .details)
            if userSettings.showProgressBar {
                VStack {
                    Text("\(Int(todoContentCopy.progress))%")
                        .font(.system(size: 25))
                        .bold()
                    Slider(value: $todoContentCopy.progress, in: 0...100)
                        .padding([.leading, .trailing], 20)
                        .padding(.bottom)
                }
            }
            
            HStack {
                Button {
                    showTaskDetails = false
                } label: {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: 135)
                        .padding(.vertical, 12)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .padding()
                Button {
                    showTaskDetails = false
                    if todoContentCopy.progress == 100 {
                        todoContentCopy.completed = true
                    } else {
                        todoContentCopy.completed = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.123) {
                        confirmClosure()
                    }
                } label: {
                    if isNewTask {
                        if todoContentCopy.content == "" {
                            Text("Create")
                                .font(.headline)
                                .foregroundColor(.blue.opacity(0.5))
                                .frame(maxWidth: 135)
                                .padding(.vertical, 12)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        } else {
                            Text("Create")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: 135)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    } else {
                        if todoContentCopy.content == "" || (todoContentCopy.content == todoContentOriginal.content && todoContentCopy.progress == todoContentOriginal.progress) {
                            Text("Confirm")
                                .font(.headline)
                                .foregroundColor(.blue.opacity(0.5))
                                .frame(maxWidth: 135)
                                .padding(.vertical, 12)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        } else {
                            Text("Confirm")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: 135)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                }
                .disabled(todoContentCopy.content == "")
            }
        }
        .onAppear {
            todoContentCopy = todoContentOriginal
            if isNewTask && userSettings.showKeyboardOnStart {
                focusField = .details
            }
        }
    }
}


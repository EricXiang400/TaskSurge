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
    var confirmClosure: () -> Void

    var body: some View {
        VStack {
            HStack {
                Text("Edit Task")
                    .font(.title)
                    .bold()
                    .padding()
                Spacer()
            }
            TextEditor(text: $todoContentCopy.content)
                .frame(height: 200)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                .padding()
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
            VStack {
                Text("\(Int(todoContentCopy.progress))%")
                    .font(.system(size: 25))
                    .bold()
                    
                Slider(value: $todoContentCopy.progress, in: 0...100)
                    .padding([.leading, .trailing], 20)
                    .padding(.bottom)
            }
            
            HStack {
                Button {
                    showTaskDetails = false
                } label: {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: 135)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding()
                Button {
                    showTaskDetails = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.123) {
                        confirmClosure()
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
            }
        }
        .onAppear {
            todoContentCopy = todoContentOriginal
        }
    }
}


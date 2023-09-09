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
    @Binding var todoContent: TodoContent
    var body: some View {
        VStack {
            HStack {
                Text("Edit Task")
                    .font(.title)
                Spacer()
            }
            TextEditor(text: $todoContent.content)
                .frame(height: 200)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
            Slider(value: $todoContent.progress, in: 0...100)
                .padding([.leading, .trailing], 20)
                .padding()
            HStack {
                Button {
                    
                } label: {
                    Text("Cancel Change")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: 135)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(8)
                }

                Button {
                    
                } label: {
                    Text("Confirm Change")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: 135)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding(.leading)
                
                
            }
            
        }
    }
}


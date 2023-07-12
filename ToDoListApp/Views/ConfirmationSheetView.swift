//
//  ConfirmationSheet.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 7/12/23.
//

import Foundation
import SwiftUI

struct ConfirmationSheetView: View {
    @Binding var showConfirmationSheet: Bool
    @Binding var listIndex: Int?
    @EnvironmentObject private var todoListContainer: TodoList

    var body: some View {
        VStack {
            Text("Are you sure you want to complete the task?")
            HStack {
                Button("Complete") {
                    showConfirmationSheet = false
                    todoListContainer.todoList[listIndex!].progress = 100.0
                    todoListContainer.todoList[listIndex!].completed = true
                    listIndex = nil
                }
                Button("Cancel") {
                    showConfirmationSheet = false
                    
                }
            }
            
        }
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

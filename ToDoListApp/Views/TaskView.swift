//
//  TaskView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 9/9/23.
//

import Foundation
import SwiftUI

struct TaskView: View {
    @Binding var todoContent: TodoContent
    @State var showTaskDetails: Bool = false
    var body: some View {
        if todoContent.completed {
            ZStack {
                TextField("Task Name", text: $todoContent.content)
                    .disabled(true)
                    .strikethrough(true)
                Button {
                    showTaskDetails = true
                    UIApplication.shared.endEditing()
                } label: {
                    Color.clear
                }
                .sheet(isPresented: $showTaskDetails) {
                    EditTaskView(todoContent: $todoContent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

        } else {
            ZStack {
                TextField("Task Name", text: $todoContent.content)
                    .disabled(true)
                Button {
                    showTaskDetails = true
                    UIApplication.shared.endEditing()
                } label: {
                    Color.clear
                }
                .sheet(isPresented: $showTaskDetails) {
                    EditTaskView(todoContent: $todoContent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        
    }
    
    
}

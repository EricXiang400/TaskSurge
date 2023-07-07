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
        return GeometryReader { geometry in
            ZStack {
                VStack(spacing: 1) {
                    Spacer()
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.1)
                            .foregroundColor(redColor)
                        Rectangle()
                            .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * geometry.size.width * 0.8, height: geometry.size.height * 0.1)
                            .foregroundColor(greenColor)
                    }
                    Text("\(Int(todoContent.progress))% ")
                        .font(.system(size: 13))
                }
                .onTapGesture {
                    presentPopOver = true
                }
                .popover(isPresented: $presentPopOver) {
                    PopOverContent(todoContent: $todoContent)
                }
            }
        }
    }
}

struct PopOverContent: View {
    @Binding var todoContent: TodoContent
    @EnvironmentObject private var todoListContainer: TodoList
    @EnvironmentObject private var selectedDateContainer: SelectedDate
    @EnvironmentObject private var curUserContainer: AppUser
    var body: some View {
        Button(action: {
            updateProgress(increment: 15.0)
            todoListContainer.saveLocalData()
            if curUserContainer.curUser != nil {
                FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
            }
        }) {
            Text("Increase by 15")
                .font(.headline)
                .foregroundColor(.blue)
                .frame(maxWidth: 125)
                .padding(.vertical, 12)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
        }
        
        Button(action: {
            updateProgress(increment: -15.0)
            todoListContainer.saveLocalData()
            if curUserContainer.curUser != nil {
                FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
            }
        }) {
            Text("Decrease by 15")
                .font(.headline)
                .foregroundColor(.red)
                .frame(maxWidth: 135)
                .padding(.vertical, 12)
                .background(Color.red.opacity(0.2))
                .cornerRadius(8)
        }
        
        Button(action: {
            todoContent.progress = 0
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
    }
    private func updateProgress(increment: Float) {
        let newProgress = todoContent.progress + increment
        todoContent.progress = max(min(newProgress, 100), 0)
        todoListContainer.saveLocalData()
        if curUserContainer.curUser != nil {
            FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
        }
    }
}

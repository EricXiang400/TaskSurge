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
    @Binding var presentPopOver: Bool
    @Binding var todoContent: TodoContent
    func makeBody(configuration: Configuration) -> some View {
        let greenColor = Color(red: 0, green: 0.7, blue: 0)
        let redColor = Color(red: 0.7, green: 0, blue: 0)
    
        return GeometryReader { geometry in
            VStack {
                Spacer()
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.1)
                        .foregroundColor(redColor)

                    Rectangle()
                        .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * geometry.size.width * 0.8, height: geometry.size.height * 0.1)
                        .foregroundColor(greenColor)
                }
                Spacer()
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

struct PopOverContent: View {
    @Binding var todoContent: TodoContent
    var body: some View {
        Button("Increase 15") {
            if (todoContent.progress + 15 <= 100) {
                todoContent.progress += 15.0
            } else {
                todoContent.progress = 100.0
            }
            
        }
        .padding()
    }
}

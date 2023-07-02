//
//  ProgressBarView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 7/2/23.
//

import Foundation
import SwiftUI


struct ProgressBarView: View {
    @State private var totalProgress: Float = 100
    @Binding var todoContent: TodoContent
    var body: some View {
        ProgressView(value: 10.0, total: totalProgress)
            .progressViewStyle(CustomProgressViewStyle())
    }
}

struct CustomProgressViewStyle: ProgressViewStyle {
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
            
        }
    }
}

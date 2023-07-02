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
        ProgressView(value: todoContent.progress, total: totalProgress)
    }
}

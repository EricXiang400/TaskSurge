//
//  SelectionButton.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 6/1/23.
//

import Foundation
import SwiftUI
struct SelectionButton: View {
    @Binding var completed: Bool
    @EnvironmentObject var envSelectedDate: SelectedDate
        var body: some View {
        Button {
            completed.toggle()
            
        } label: {
            Label("Toggle Selected", systemImage: completed ?  "circle.fill" : "circle")
                .labelStyle(.iconOnly)
        }
    }
}


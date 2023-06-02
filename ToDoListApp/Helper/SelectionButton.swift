//
//  SelectionButton.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 6/1/23.
//

import Foundation
import SwiftUI
struct SelectionButton: View {
    @Binding var selected: Bool
    var body: some View {
        Button {
            selected.toggle()
        } label: {
            Label("Toggle Selected", systemImage: selected ?  "circle.fill" : "circle")
                .labelStyle(.iconOnly)
        }
    }
}

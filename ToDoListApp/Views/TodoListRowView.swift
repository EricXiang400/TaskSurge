//
//  TodoListRow.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 5/30/23.
//

import Foundation
import SwiftUI

struct TodoListRowView: View {
    var todo: TodoContent
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: "circle")
                .padding(5)
            Text("\(todo.content)")
            Spacer()
        }
    }
}

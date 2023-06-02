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
    @EnvironmentObject var modelData: ModelData
    var todoIndex: Int {
        $modelData.todos.firstIndex(where: {$0.id == todo.id})!
    }
    var body: some View {
        HStack(spacing: 20) {
            SelectionButton(completed: $modelData.todos[todoIndex].completed)
                .padding(5)
            Text("\(todo.content)")
            Spacer()
        }
    }
}

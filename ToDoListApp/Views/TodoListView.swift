//
//  TodoListView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 5/30/23.
//

import Foundation
import SwiftUI

struct TodoListView: View {
    @EnvironmentObject var modelData: ModelData
    var body: some View {
        VStack {
            ForEach(modelData.todos) { todo in
                TodoListRowView(todo: todo)
            }
        }
    }
}

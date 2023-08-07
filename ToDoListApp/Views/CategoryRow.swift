//
//  CategoryRow.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 8/2/23.
//

import Foundation
import SwiftUI

struct CategoryRow: View {
    @EnvironmentObject var categoryContainer: CategoriesData
    @EnvironmentObject var todoListContainer: TodoList
    @Binding var category: Category
    @State var isEditing: Bool = false
    var delete: () -> Void
    var body: some View {
        HStack {
            if isEditing {
                TextField("Category", text: $category.name, onCommit: {
                    if category.name != "" {
                        categoryContainer.saveLocalCategories()
                    }
                })
            } else {
                Text(category.name)
            }
            Spacer()
            Button {
                isEditing.toggle()
            } label: {
                HStack {
                    if todoListContainer.category == category {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                    if !isEditing {
                        Image(systemName: "pencil")
                    }
                    
                }
            }
            if isEditing {
                Button {
                    delete()
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .foregroundColor(.black)
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(category.color)
        .cornerRadius(10)
        .onTapGesture {
            todoListContainer.category = category
            print("Selcted")
        }
    }
}

extension Category: Equatable {
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
}

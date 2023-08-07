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
                if !isEditing {
                    Image(systemName: "pencil")
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
    }
    
}

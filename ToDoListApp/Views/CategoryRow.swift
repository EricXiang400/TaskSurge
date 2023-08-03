//
//  CategoryRow.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 8/2/23.
//

import Foundation
import SwiftUI

struct CategoryRow: View {
    @EnvironmentObject var categoryContainer: Category
//    @Binding var category: String
    @State var isEditing: Bool = false
    var index: Int
    
    var body: some View {
        HStack {
            if isEditing {
                TextField("Category", text: $categoryContainer.categories[index])
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                Text(categoryContainer.categories[index])
            }
            Button {
                isEditing.toggle()
            } label: {
                Image(systemName: self.isEditing ? "checkmark" : "pencil")
            }
            Button {
                categoryContainer.categories.remove(at: index)
            } label: {
                Image(systemName: "trash")
            }
        }
    }
}

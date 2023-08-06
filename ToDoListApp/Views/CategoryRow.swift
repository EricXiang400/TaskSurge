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
    @Binding var category: String
    @State var isEditing: Bool = false
    var delete: () -> Void
    var body: some View {
        HStack {
            if isEditing {
                TextField("Category", text: $category)
            } else {
                Text(category)
            }
            Spacer()
            Button {
                isEditing.toggle()
            } label: {
                Image(systemName: self.isEditing ? "checkmark" : "pencil")
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
        .background(Color.orange)
        .cornerRadius(10)
        
    }
}

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
    @EnvironmentObject var curUserContainer: AppUser
    @Binding var category: Category
    @Binding var categoryIndex: Int
    @State var toggleUIUpdate: Bool = false
    var localCategoryIndex: Int
    var delete: () -> Void
    var body: some View {
        HStack {
            if category.isEditing {
                TextField("Category", text: $category.name, onCommit: {
                    if category.name != "" {
                        categoryContainer.saveLocalCategories()
                        if curUserContainer.curUser != nil {
                            FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                        }
                    }
                })
            } else {
                Text(category.name)
            }
            Spacer()
            Button {
                category.isEditing.toggle()
                toggleUIUpdate.toggle()
            } label: {
                HStack {
                    if todoListContainer.category == category && !category.isEditing {
                        Image(systemName: "pencil")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                            
                    } else if !category.isEditing {
                        Image(systemName: "pencil")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                }
            }
            if category.isEditing {
                Button {
                    category.isEditing = false
                    categoryContainer.saveLocalCategories()
                    if curUserContainer.curUser != nil {
                        FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                    }
                    UIApplication.shared.endEditing()
                    toggleUIUpdate.toggle()
                } label: {
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 18, height: 18)
                }
                Button {
//                    withAnimation(.easeOut) {
                        delete()
//                    }
                    UIApplication.shared.endEditing()
                    toggleUIUpdate.toggle()
                } label: {
                    Image(systemName: "trash")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(red: 0.9, green: 0, blue: 0))
                }
            }
        }
        .foregroundColor(.black)
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(category.color)
        .cornerRadius(10)
        .onTapGesture {
            UIApplication.shared.endEditing()
            if categoryIndex != localCategoryIndex {
                categoryContainer.categories[categoryIndex].isEditing = false
            }
            categoryIndex = localCategoryIndex
            todoListContainer.category = category
            todoListContainer.saveLocalCategory()
            if curUserContainer.curUser != nil {
                FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
            }
        }
    }
}

extension Category: Equatable {
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
}

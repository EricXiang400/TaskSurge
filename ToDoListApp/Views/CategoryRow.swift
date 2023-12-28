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
    @State var toggleUIUpdate: Bool = false
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
                .font(.system(size: 17, weight: .bold, design: .default))
                    .cornerRadius(5)
            } else {
                Text(category.name)
                    .font(.system(size: 17, weight: .bold, design: .default))
                        .cornerRadius(5)
            }
            Spacer()
            Button {
                category.isEditing.toggle()
                toggleUIUpdate.toggle()
            } label: {
                HStack {
                    if todoListContainer.selectedCategory == category && !category.isEditing {
                        Image(systemName: "pencil")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "")
                            .resizable()
                            .frame(width: 25, height: 25)
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
                    delete()
                    UIApplication.shared.endEditing()
                    toggleUIUpdate.toggle()
                } label: {
                    Image(systemName: "trash")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(red: 0.9, green: 0, blue: 0))
                }
            }
            if (getNumUnfinished() != 0) {
                Circle()
                    .foregroundColor(Color(red: 0.9, green: 0.1, blue: 0.1))
                    .frame(width: 25, height: 25)
                    .overlay(
                        Text("\(getNumUnfinished())")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .fontWeight(.heavy)
                    )
            }
        }
        .foregroundColor(.black)
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(category.color)
        .cornerRadius(10)
        .onTapGesture {
            UIApplication.shared.endEditing()
            todoListContainer.selectedCategory = category
            todoListContainer.selectedCategory?.saveLocalCategory()
            if curUserContainer.curUser != nil {
                FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
            }
        }
    }
    
    func getNumUnfinished() -> Int {
        return todoListContainer.todoList.filter { todoContent in
            todoContent.category == category && !todoContent.completed
        }.count
    }
}

extension Category: Equatable {
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
}

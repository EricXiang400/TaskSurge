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
    @Environment(\.colorScheme) var colorScheme
    @Binding var category: Category
    @State var toggleUIUpdate: Bool = false
    @State var showDeleteCategoryAlert: Bool = false
    var delete: () -> Void
    var body: some View {
        HStack {
            if (getNumUnfinished() != 0) {
                Circle()
                    .foregroundColor(Color(red: 0.9, green: 0.1, blue: 0.1))
                    .frame(width: 15, height: 15)
            } else {
                Circle()
                    .foregroundColor(Color(red: 0.2, green: 0.9, blue: 0.2))
                    .frame(width: 15, height: 15)
            }
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
                    showDeleteCategoryAlert.toggle()
                } label: {
                    Image(systemName: "trash")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(red: 0.9, green: 0, blue: 0))
                }
                .alert(isPresented: $showDeleteCategoryAlert) {
                    Alert(title: Text("Are you sure you want to delete this category?"),
                          message: Text("Deleting this category will delete all todos created under this category"),
                          primaryButton: .default(Text("Confirm")) {
                        delete()
                        UIApplication.shared.endEditing()
                        toggleUIUpdate.toggle()
                        showDeleteCategoryAlert.toggle()
                    },
                          secondaryButton: .cancel()
                    )
                }
            }
            if (getNumUnfinished() != 0) {
                Circle()
                    .foregroundColor(Color(red: 0.9, green: 0.1, blue: 0.1))
                    .frame(width: 25, height: 25)
                    .overlay(
                        Text("\(getNumUnfinished())")
                            .font(.system(size: 15))
                            .foregroundColor(colorScheme == .dark ? Color(red: 0.9, green: 0.9, blue: 0.9) : .white)
                            .fontWeight(.heavy)
                    )
            }
        }
        .foregroundColor(colorScheme == .dark ? .white : .black)
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2).opacity(0.5) : Color(red: 0.925, green: 0.925, blue: 0.925))
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

//
//  MenuContent.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 7/11/23.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct MenuContentView: View {
    @EnvironmentObject var curUserContainer: AppUser
    @EnvironmentObject private var todoListContainer: TodoList
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var categoryContainer: CategoriesData
    @Binding var isShowingSetting: Bool
    @Binding var showLoginView: Bool
    @Environment(\.colorScheme) var colorScheme
    @Binding var showSideMenu: Bool
    @State var categoryIndex: Int = 0
    let fromTopTransition = AnyTransition.opacity.combined(with: .offset(y: -25))
    var menuItems: [MenuItem] = [MenuItem(itemName: "Feedbacks"), MenuItem(itemName: "Privacy"), MenuItem(itemName: "About Us")]
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button (action: {
                    withAnimation(.easeInOut) {
                        showSideMenu = false
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                }
                .padding(.leading, 6.5)
                Spacer()
            }
            .padding()
            HStack {
                Image(systemName: "person.circle")
                    .font(.system(size: 28))
                    .padding(.leading, 18)
                if curUserContainer.curUser != nil {
                    Text("Hi, \(TodoList.loadLocalUser()?.userName ?? "Unknown")")
                    Button("Sign out") {
                        if signOut() {
                            curUserContainer.curUser = nil
                            todoListContainer.todoList = TodoList.loadLocalData(user: nil)
                            userSettings.loadLocalSettings(user: curUserContainer.curUser)
                        }
                    }
                } else {
                    Button("Log in") {
                        showLoginView = true
                    }
                    .sheet(isPresented: $showLoginView) {
                        LogInView(showLoginView: $showLoginView, showSideWindow: $showSideMenu)
                    }
                }
            }
            
            ScrollView {
                ForEach(Array(categoryContainer.categories.enumerated()), id: \.offset) { index, strElem in
                    HStack {
                        Spacer()
                        CategoryRow(category: $categoryContainer.categories[index], categoryIndex: $categoryIndex, localCategoryIndex: index,delete: {
                            if todoListContainer.category == categoryContainer.categories[index] {
                                todoListContainer.category = nil
                            }
                            categoryContainer.categories.remove(at: index)
                            categoryContainer.saveLocalCategories()
                            if curUserContainer.curUser != nil {
                                FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                            }
                        })
                        Spacer()
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15))
                    .transition(fromTopTransition)
                    .animation(.easeInOut)
                }
            }
            .transition(.identity)

            Spacer()
            HStack {
                Spacer()
                Button (action: {
                    UIApplication.shared.endEditing()
                    categoryContainer.categories.append(Category(name: "Untitled"))
                    categoryContainer.saveLocalCategories()
                    if curUserContainer.curUser != nil {
                        FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                    }
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .padding(.horizontal, 125)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                Spacer()
            }
            .padding()
            HStack {
                // Settings button
                Button (action: {
                    UIApplication.shared.endEditing()
                    isShowingSetting = true
                }) {
                    Image(systemName: "gearshape") // SF Symbol for settings
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .padding(.leading)
                Spacer()
            }
        }
        .onAppear {
            categoryContainer.categories = CategoriesData.loadLocalCategories()
            var curCategory = TodoList.loadLocalCategory(user: curUserContainer.curUser)
            if curCategory != nil && categoryContainer.categories.contains(curCategory!) {
                todoListContainer.category = curCategory
            }
        }
    }
    
    func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            showSideMenu = false
            return true
        } catch let signOutError_ as NSError {
            print("Error signing out")
            return false
        }
    }
}

struct MenuItem: Identifiable, Hashable {
    static var lastAssignedID: Int = 0
    var itemName: String
    var id: Int
    
    init(itemName: String) {
        self.itemName = itemName
        MenuItem.lastAssignedID += 1
        self.id = MenuItem.lastAssignedID
    }
}


extension Color {
    static func primaryColor(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .light ? Color.white : Color.black
    }
}


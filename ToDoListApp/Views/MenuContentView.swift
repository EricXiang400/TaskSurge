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
    @EnvironmentObject var categoryContainer: Category
    @Binding var isShowingSetting: Bool
    @Binding var showLoginView: Bool
    @Binding var showSideMenu: Bool
    var menuItems: [MenuItem] = [MenuItem(itemName: "Feedbacks"), MenuItem(itemName: "Privacy"), MenuItem(itemName: "About Us")]
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button (action: {
                    showSideMenu = false
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
            
        
            ForEach(Array(categoryContainer.categories.enumerated()), id: \.offset) {index, strElem in
                CategoryRow(category: $categoryContainer.categories[index], delete: {
                    categoryContainer.categories.remove(at: index)
                })
            }
            
            Button (action: {
                categoryContainer.categories.append("")
            }) {
                Circle()
                    .foregroundColor(.blue)
                    .frame(width: 25, height: 25)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    )
                    .padding()
            }
            
            
            Spacer()
            HStack {
                // Settings button
                Button (action: {
                    isShowingSetting = true
                }) {
                    Image(systemName: "gearshape") // SF Symbol for settings
                        .resizable()
                        .frame(width: 30, height: 30)
                }
//                .fullScreenCover(isPresented: $isShowingSetting) {
//                    SettingsView(isShowingSetting: $isShowingSetting)
//                }
                .padding(.leading)
                Spacer()
            }
        }
        .onAppear {
            categoryContainer.categories = Category.loadLocalCategories()
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



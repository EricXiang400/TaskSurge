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
    @EnvironmentObject private var curUserContainer: AppUser
    @EnvironmentObject private var todoListContainer: TodoList
    @Binding var showLoginView: Bool
    @Binding var showSideMenu: Bool
    var menuItems: [MenuItem] = [MenuItem(itemName: "Subscriptions"), MenuItem(itemName: "Privacy"), MenuItem(itemName: "About us")]
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
                            todoListContainer.todoList = []
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
            List {
                ForEach(menuItems) { item in
                    NavigationLink(item.itemName) {
                        EmptyView()
                    }
                    .frame(width: 200, height: 25)
                }
            }
            .listStyle(.plain)
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

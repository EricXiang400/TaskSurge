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
    var body: some View {
        VStack {
            Image(systemName: "person.circle")
                .font(.system(size: 28))
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
                    LogInView(showLoginView: $showLoginView)
                }
            }
        }
    }
    func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            return true
        } catch let signOutError_ as NSError {
            print("Error signing out")
            return false
        }
    }
}

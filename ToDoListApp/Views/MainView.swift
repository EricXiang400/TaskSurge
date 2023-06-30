//
//  ContentView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 5/30/23.
//

import SwiftUI
import FirebaseAuth

struct MainView: View {
    @State var showLoginView = false
    @EnvironmentObject private var curUserContainer: AppUser
    @EnvironmentObject private var todoListContainer: TodoList
    var body: some View {
        VStack {
            HStack {
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
            CalenderView()
            TodoListView()
            Spacer()
        }
    }
    
    func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            return true
        } catch let signOutError as NSError {
            print("Error signing out")
            return false
        }
    }
}

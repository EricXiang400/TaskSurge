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
    @State var curUser: User?
    var body: some View {
        VStack {
            if curUser != nil {
                Text("Hi, \(curUser!.displayName ?? "Unknown")")
                Button("Sign out") {
                    if signOut() {
                        curUser = nil
                    }
                }
            } else {
                Button("Log in") {
                    showLoginView = true
                }
                .sheet(isPresented: $showLoginView) {
                    LogInView(showLoginView: $showLoginView, curUser: $curUser)
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

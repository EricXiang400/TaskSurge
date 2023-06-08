//
//  ContentView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 5/30/23.
//

import SwiftUI

struct MainView: View {
    @State var showLoginView = false
    
    var body: some View {
        VStack {
            Button("Log in") {
                showLoginView = true
            }
            .sheet(isPresented: $showLoginView) {
                LogInView()
            }
            CalenderView()
            TodoListView()
            Spacer()
        }
    }
}

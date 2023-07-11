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
    @State var showSideMenu = false
    @EnvironmentObject private var curUserContainer: AppUser
    @EnvironmentObject private var todoListContainer: TodoList
    var body: some View {
        ZStack {
            VStack {
                CalenderView()
                TodoListView()
            }
            if showSideMenu {
                SideMenuView(showSideMenu: $showSideMenu)
                    .frame(width: 300)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showSideMenu = false
                    }
            }
            
        }
        .gesture(DragGesture().onEnded({ value in
            if value.translation.width > 100 {
                showSideMenu = true
            }
        })
        )
        .ignoresSafeArea(.all)
    }
}

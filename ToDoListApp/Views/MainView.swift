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
    @State var showCalendar: Bool = true
    var body: some View {
        ZStack {
            TodoListView(showCalendar: $showCalendar, showSideMenu: $showSideMenu)
            if showSideMenu {
                Color.black.opacity(0.5)
                    .ignoresSafeArea(.all)
                HStack {
                    SideMenuView(showSideMenu: $showSideMenu)
                        .frame(width: UIScreen.main.bounds.width * (3/4), alignment: .leading)
                        .animation(.easeOut(duration: 0.3), value: showSideMenu)
                    Spacer()
                }
            }
        }
    }
}

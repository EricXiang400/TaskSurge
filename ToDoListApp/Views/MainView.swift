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
    @GestureState private var dragOffset: CGFloat = 0
    @EnvironmentObject private var curUserContainer: AppUser
    @EnvironmentObject private var todoListContainer: TodoList
    @State var showCalendar: Bool = false
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showCalendar.toggle()
                    }) {
                        if showCalendar {
                            Image(systemName: "calendar")
                        } else {
                            Image(systemName: "calendar.badge.plus")
                        }
                    }
                    .padding()
                }
                if showCalendar {
                    CalenderView()
                }
                TodoListView()
            }
            if showSideMenu {
                HStack {
                    SideMenuView(showSideMenu: $showSideMenu)
                        .frame(width: UIScreen.main.bounds.width * (3/4), alignment: .leading)
                        .offset(x: showSideMenu ? 0 : -300 + dragOffset)
                        .animation(.easeOut(duration: 0.3), value: showSideMenu)
                    Spacer()
                }
            }
        }
        .gesture(DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation.width
            }
            .onEnded { value in
                if value.translation.width > 25 {
                    showSideMenu = true
                } else {
                    showSideMenu = false
                }
            }
        )
    }
}

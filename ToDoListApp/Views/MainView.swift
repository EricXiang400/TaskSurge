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
    @State var isShowSettingView: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @State var showProgressEditView: Bool = false
    @State var selectedTodoContent: TodoContent = TodoContent(content: "", completed: false, date: Date())
    @State var slideBarAmount: Float = 0
    var body: some View {
        ZStack {
            VStack {
                CalendarView()
                    .zIndex(0)
                TodoListView(showCalendar: $showCalendar, showSideMenu: $showSideMenu, selectedTodoContent: $selectedTodoContent, showProgressEditView: $showProgressEditView)
                    .background(Color.primaryColor(for: colorScheme))
                    .zIndex(0)
            }
            
            
            if showSideMenu {
                Color.black.opacity(0.5)
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            showSideMenu = false
                        }
                    }
                ZStack {
                    Color.primaryColor(for: colorScheme)
                        .frame(width: UIScreen.main.bounds.width * (3/4), alignment: .leading)
                        .ignoresSafeArea(.all)
                        .offset(x: -55)
                        .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
                    MenuContentView(isShowingSetting: $isShowSettingView, showLoginView: $showLoginView, showSideMenu: $showSideMenu)
                        .frame(width: UIScreen.main.bounds.width * (3/4), alignment: .leading)
                        .offset(x: -55)
                }
                .zIndex(1)
                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
            }

            if isShowSettingView {
                SettingsView(isShowingSetting: $isShowSettingView)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(colorScheme == .dark ? Color.black.edgesIgnoringSafeArea(.all): Color.white.edgesIgnoringSafeArea(.all)) // Set background color
                    .transition(.move(edge: .leading))
                    .animation(.easeInOut)
                    .zIndex(1)
            }
            
            if showProgressEditView {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea(.all)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                showProgressEditView = false
                            }
                        }
                        .zIndex(1)
                    PopOverContent(todoContent: $selectedTodoContent, presentPopOver: $showProgressEditView, slideBarAmount: $slideBarAmount)
                        .onAppear {
                            slideBarAmount = selectedTodoContent.progress
                        }
                        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 3, alignment: .bottom)

                        .background(colorScheme == .dark ? Color.black.edgesIgnoringSafeArea(.all) : Color.white.edgesIgnoringSafeArea(.all))
                        .cornerRadius(15)
                        .offset(y: 300)
                        .transition(.move(edge: .bottom))
                        .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
                        .zIndex(2)
            }
        }
    }
}


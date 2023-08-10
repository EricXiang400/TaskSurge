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
            TodoListView(showCalendar: $showCalendar, showSideMenu: $showSideMenu, selectedTodoContent: $selectedTodoContent, showProgressEditView: $showProgressEditView)
            if showSideMenu {
                Color.black.opacity(0.5)
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        showSideMenu = false
                    }
                HStack {
                    SideMenuView(showSideMenu: $showSideMenu, isShowSettingView: $isShowSettingView)
                        .frame(width: UIScreen.main.bounds.width * (3/4), alignment: .leading)
                        .animation(.easeOut(duration: 0.3), value: showSideMenu)
                    Spacer()
                }
            }
            
            HStack {
                if isShowSettingView {
                    SettingsView(isShowingSetting: $isShowSettingView)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(colorScheme == .dark ? Color.black.edgesIgnoringSafeArea(.all) : Color.white.edgesIgnoringSafeArea(.all)) // Set background color
        //                    .transition(.move(edge: .leading))
                        .transition(.asymmetric(insertion: AnyTransition.opacity.combined(with: .offset(x: UIScreen.main.bounds.width, y: 0)).combined(with: .move(edge: .leading)), removal: AnyTransition.opacity.combined(with: .offset(x: -UIScreen.main.bounds.width, y: 0))).combined(with: .move(edge: .leading)))
                        .animation(.easeInOut)
                }
            }
            if showProgressEditView {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea(.all)
                        .onTapGesture {
                            showProgressEditView = false
                        }
                        PopOverContent(todoContent: $selectedTodoContent, presentPopOver: $showProgressEditView, slideBarAmount: $slideBarAmount)
                            .onAppear {
                                slideBarAmount = selectedTodoContent.progress
                            }
                            .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 3, alignment: .bottom)
                            
                            .background(colorScheme == .dark ? Color.black.edgesIgnoringSafeArea(.all) : Color.white.edgesIgnoringSafeArea(.all))
                            .cornerRadius(15)
                            .offset(y: 300)
                            .transition(.move(edge: .bottom))
                            .animation(.easeInOut)
                }
            }
            
        }
    }
}

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
    @State var sideMenuOffset: CGFloat = -UIScreen.main.bounds.width * (3/4) - 55
    var body: some View {
        ZStack {
            VStack {
                CalendarView()
                TodoListView(showCalendar: $showCalendar, showSideMenu: $showSideMenu, selectedTodoContent: $selectedTodoContent, showProgressEditView: $showProgressEditView, sideMenuOffset: $sideMenuOffset)
                    .background(Color.primaryColor(for: colorScheme))
                }
                .zIndex(0)
            
                if showSideMenu {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea(.all)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.23)) {
                                showSideMenu = false
                                sideMenuOffset = -UIScreen.main.bounds.width * (3/4) - 55
                            }
                        }
                }
                ZStack {
                    Color.white.opacity(0.0000001)
                        .frame(width: UIScreen.main.bounds.width * (3/4) + 20, alignment: .leading)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.23)) {
                                showSideMenu = true
                                sideMenuOffset = -55
                            }
                        }
                    if (colorScheme == .dark) {
                        Color(red: 0.1, green: 0.1, blue: 0.1)
                            .frame(width: UIScreen.main.bounds.width * (3/4), alignment: .leading)
                            .ignoresSafeArea(.all)
                            .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
                    } else {
                        Color.primaryColor(for: colorScheme)
                            .frame(width: UIScreen.main.bounds.width * (3/4), alignment: .leading)
                            .ignoresSafeArea(.all)
                            .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
                    }

                    MenuContentView(isShowingSetting: $isShowSettingView, showLoginView: $showLoginView, showSideMenu: $showSideMenu, menuOffset: $sideMenuOffset)
                        .frame(width: UIScreen.main.bounds.width * (3/4), alignment: .leading)
                }
                .offset(x: sideMenuOffset)
                .gesture(DragGesture()
                    .onChanged({ value in
                        if value.translation.width > 5 {
                            sideMenuOffset = min(value.location.x - UIScreen.main.bounds.width * (3/4), -55)
                        }
                    }
                              )
                    .onEnded({ value in
                        if value.startLocation.x - value.predictedEndLocation.x > 5 {
                            withAnimation(.easeInOut(duration: 0.23)) {
                                showSideMenu = false
                                sideMenuOffset = -UIScreen.main.bounds.width * (3/4) - 55
                            }
                        } else if value.predictedEndLocation.x - value.startLocation.x > 5 {
                            withAnimation(.easeInOut(duration: 0.23)) {
                                sideMenuOffset = -55
                                showSideMenu = true
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.23)) {
                                showSideMenu = false
                                sideMenuOffset = -UIScreen.main.bounds.width * (3/4) - 55
                            }
                        }
                    })
                )
            
            
                .zIndex(1)
                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
//        }

            if isShowSettingView {
                SettingsView(isShowingSetting: $isShowSettingView)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.1).edgesIgnoringSafeArea(.all): Color.white.edgesIgnoringSafeArea(.all)) // Set background color
                    .transition(.move(edge: .leading))
                    .animation(.easeInOut)
                    .zIndex(1)
            }
            
            if showProgressEditView {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea(.all)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showProgressEditView = false
                            }
                        }
                        .zIndex(1)
                    PopOverContent(todoContent: $selectedTodoContent, presentPopOver: $showProgressEditView, slideBarAmount: $slideBarAmount)
                        .onAppear {
                            slideBarAmount = selectedTodoContent.progress
                        }
                        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 3, alignment: .bottom)

                        .background(colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.1).edgesIgnoringSafeArea(.all) : Color.white.edgesIgnoringSafeArea(.all))
                        .cornerRadius(15)
                        .offset(y: 300)
                        .transition(.move(edge: .bottom))
                        .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
                        .zIndex(2)
            }
        }
    }
}


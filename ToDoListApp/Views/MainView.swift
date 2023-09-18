//
//  ContentView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 5/30/23.

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
    @State var settingViewOffset: CGFloat = -440
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
                            withAnimation(.easeInOut(duration: 0.22)) {
                                showSideMenu = false
                                sideMenuOffset = -UIScreen.main.bounds.width * (3/4) - 55
                            }
                        }
                }
                ZStack {
                    Color.white.opacity(0.0000001)
                        .frame(width: UIScreen.main.bounds.width * (3/4) + 35, alignment: .leading)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.22)) {
                                print(sideMenuOffset)
                                showSideMenu = true
                                sideMenuOffset = -55
                            }
                        }
                        .zIndex(0)
                       
                    if (colorScheme == .dark) {
                        Color(red: 0.1, green: 0.1, blue: 0.1)
                            .frame(width: UIScreen.main.bounds.width * (3/4), alignment: .leading)
                            .ignoresSafeArea(.all)
                            .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
                            .zIndex(1)
                    } else {
                        Color.primaryColor(for: colorScheme)
                            .frame(width: UIScreen.main.bounds.width * (3/4), alignment: .leading)
                            .ignoresSafeArea(.all)
                            .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
                            .zIndex(1)
                    }

                    MenuContentView(isShowingSetting: $isShowSettingView, showSideMenu: $showSideMenu, menuOffset: $sideMenuOffset, settingViewOffset: $settingViewOffset)
                        .frame(width: UIScreen.main.bounds.width * (3/4), alignment: .leading)
                        .zIndex(2)
                        
                }
                
                .gesture(DragGesture()
                    .onEnded({ value in
                        if value.translation.width < -5 {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                sideMenuOffset = -UIScreen.main.bounds.width * (3/4) - 55
                                showSideMenu = false
                                print(value.translation.width)
                            }
                        } else if value.translation.width > 5 && sideMenuOffset != -55 {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                sideMenuOffset = -55
                                showSideMenu = true
                            }
                        }
                    })
                )
                .zIndex(1)
                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                .offset(x: sideMenuOffset)

            if isShowSettingView {
                SettingsView(isShowingSetting: $isShowSettingView, settingViewOffset: $settingViewOffset)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.1).edgesIgnoringSafeArea(.all): Color.white.edgesIgnoringSafeArea(.all)) // Set background color
                    .offset(x: settingViewOffset)
                    
                    .gesture(DragGesture()
                        .onEnded({ value in
                            if value.translation.width < -25 {
                                withAnimation(.easeInOut(duration: 0.22)) {
                                    isShowSettingView = false
                                    settingViewOffset = -440
                                }
                            } else {
                                withAnimation(.easeInOut(duration: 0.22)) {
                                    isShowSettingView = true
                                    settingViewOffset = 0
                                }
                            }
                        })
                    )
                    .transition(.move(edge: .leading))
                    .zIndex(1)
            }
            
            if showProgressEditView {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea(.all)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.22)) {
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


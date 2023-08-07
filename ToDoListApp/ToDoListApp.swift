//
//  ToDoListAppApp.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 5/30/23.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct ToDoListApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var selectedDate = SelectedDate()
    @StateObject private var todos: TodoList = TodoList()
    @StateObject private var curUser: AppUser = AppUser()
    @StateObject private var userSettings: UserSettings = UserSettings()
    @StateObject private var categories: CategoriesData = CategoriesData()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(selectedDate)
                .environmentObject(todos)
                .environmentObject(curUser)
                .environmentObject(userSettings)
                .environmentObject(categories)
                .preferredColorScheme(userSettings.darkMode ? .dark : .light)
        }
    }
}

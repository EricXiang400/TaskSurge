//
//  ToDoListAppApp.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 5/30/23.
//

import SwiftUI
import Firebase

@main
struct ToDoListApp: App {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var selectedDateContainer = SelectedDate()
    @StateObject private var todoListContainer: TodoList = TodoList()
    @StateObject private var curUserContainer: AppUser = AppUser(uid: "", userName: "")
    @StateObject private var userSettingsContainer: UserSettings = UserSettings()
    @StateObject private var categoriesContainer: CategoriesData = CategoriesData()
    @StateObject private var lastModifiedTimeContainer: LastModifiedTime = LastModifiedTime()
    @StateObject private var lastModifiedByContainer: LastModifiedBy = LastModifiedBy(lastModifiedBy: "")
    @State private var dataJustSentContainer: Bool = false
    init() {
        FirebaseApp.configure()
        if UserDefaults.standard.object(forKey: "hasLaunchedBefore") == nil {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            todoListContainer.initData()
            todoListContainer.saveLocalData()
            curUserContainer.initUser()
            categoriesContainer.initData()
            categoriesContainer.saveLocalCategories()
            userSettingsContainer.initData()
            userSettingsContainer.saveLocalSettings()
            selectedDateContainer.selectedDate = Date()
            lastModifiedTimeContainer.lastModifiedTime = Date()
            lastModifiedTimeContainer.saveData()
            lastModifiedByContainer.changeDeviceUUID()
            lastModifiedByContainer.saveData()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(selectedDateContainer)
                .environmentObject(todoListContainer)
                .environmentObject(curUserContainer)
                .environmentObject(userSettingsContainer)
                .environmentObject(categoriesContainer)
                .environmentObject(lastModifiedTimeContainer)
                .environmentObject(lastModifiedByContainer)
                .preferredColorScheme(userSettingsContainer.darkMode ? .dark : .light)
        }
    }
}
extension ColorScheme {
    static let lightDark = Color(red: 0.1, green: 0.1, blue: 0.1)
}

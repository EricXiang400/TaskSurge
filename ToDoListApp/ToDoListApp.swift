//
//  ToDoListAppApp.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 5/30/23.
//

import SwiftUI


@main
struct ToDoListApp: App {
//    @StateObject private var modelData = ModelData()
    @StateObject private var selectedDate = SelectedDate()
    var body: some Scene {
        WindowGroup {
            MainView()
//                .environmentObject(modelData)
                .environmentObject(selectedDate)
        }
    }
}

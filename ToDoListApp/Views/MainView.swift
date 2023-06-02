//
//  ContentView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 5/30/23.
//

import SwiftUI

struct MainView: View {
    @State var selectedDate: Date = Date()
    var body: some View {
        VStack {
            CalenderView(selectedDate: $selectedDate)
            TodoListView()
        }
    }
}

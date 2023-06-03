//
//  ContentView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 5/30/23.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            CalenderView()
            TodoListView()
            Spacer()
        }
    }
}

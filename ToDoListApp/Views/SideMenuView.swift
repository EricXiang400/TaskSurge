//
//  SideMenuView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 7/11/23.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct SideMenuView: View {
    @State var showLoginView: Bool = false
    @EnvironmentObject private var curUserContainer: AppUser
    @EnvironmentObject private var todoListContainer: TodoList
    @Binding var showSideMenu: Bool
    var body: some View {
        ZStack {
            // Dimmed background view
            GeometryReader { _ in
                EmptyView()
            }
            .background(Color.white)
            .opacity (showSideMenu ? 1 : 0)
            .animation(Animation.easeIn.delay (0.25))
            .onTapGesture {
                showSideMenu.toggle()
            }
            HStack {
                MenuContentView(showLoginView: $showLoginView)
            }
        }
    }
    
    
}


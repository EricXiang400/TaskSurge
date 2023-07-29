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
    @Environment(\.colorScheme) var colorScheme
    @Binding var isShowSettingView: Bool
    var body: some View {
        ZStack {
            GeometryReader { _ in
                EmptyView()
            }
            .background(Color.primaryColor(for: colorScheme))
            .opacity (showSideMenu ? 1 : 0)
            MenuContentView(isShowingSetting: $isShowSettingView, showLoginView: $showLoginView, showSideMenu: $showSideMenu)
        }
    }
}

extension Color {
    static func primaryColor(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .light ? Color.white : Color.black
    }
}

//
//  SettingsView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 7/27/23.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var curUserContainer: AppUser
    @EnvironmentObject private var todoListContainer: TodoList
    @EnvironmentObject var userSettings: UserSettings
    @Binding var isShowingSetting: Bool
    var body: some View {
        VStack {
            HStack {
                Button (action: {
                    withAnimation {
                        isShowingSetting = false
                       }
                }) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                }
                .padding(.leading)
                Spacer()
            }
            HStack {
                Text("Settings")
                    .font(.title)
                    .bold()
                    .padding()
                Spacer()
            }
            Spacer()
            VStack {
                Toggle(isOn: $userSettings.darkMode) {
                    Text("Dark Mode")
                }
                .onChange(of: userSettings.darkMode) { newValue in
                    userSettings.darkMode = newValue
                    userSettings.saveLocalSettings()
                    if curUserContainer.curUser != nil {
                        FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                    }
                }
                .padding()
                Spacer()
            }
        }
    }
}

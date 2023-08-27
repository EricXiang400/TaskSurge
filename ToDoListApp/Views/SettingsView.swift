//
//  SettingsView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 7/27/23.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var curUserContainer: AppUser
    @EnvironmentObject private var todoListContainer: TodoList
    @EnvironmentObject var userSettings: UserSettings
    @Binding var isShowingSetting: Bool
    @State var showDeleteAccountAlert: Bool = false
    @State var showReauthenticationView: Bool = false
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
            if curUserContainer.curUser != nil {
                Button {
                    showDeleteAccountAlert = true
                } label: {
                    Text("Delete Account")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.horizontal, 75)
                        .padding(.vertical, 10)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .alert(isPresented: $showDeleteAccountAlert) {
                    Alert(title: Text("Are you sure you want to delete your account?"),
                          message: Text("Deleting your account will delete all of your user data and profile"),
                          primaryButton: .default(Text("Confirm")) {
                        showReauthenticationView = true
                    },
                          secondaryButton: .cancel()
                    )
                }
                .sheet(isPresented: $showReauthenticationView) {
                    ReAuthenticationView(showReauthenticationView: $showReauthenticationView, isShowingSetting: $isShowingSetting)
                }
            }
        }
    }
}

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
    @EnvironmentObject var categoryContainer: CategoriesData
    @Binding var isShowingSetting: Bool
    @State var showDeleteAccountAlert: Bool = false
    @State var showReauthenticationView: Bool = false
    @Binding var settingViewOffset: CGFloat
    @State var showLoginView: Bool = false
    var body: some View {
        VStack {
            HStack {
                Button (action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isShowingSetting = false
                        settingViewOffset = 0
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
                HStack {
                    Image(systemName: "person.circle")
                        .font(.system(size: 28))
                        .padding(.leading, 18)
                    if curUserContainer.curUser != nil {
                        Text("Hi, \(TodoList.loadLocalUser()?.userName ?? "Unknown")")
                            .bold()
                        Button {
                            if signOut() {
                                curUserContainer.curUser = nil
                                todoListContainer.loadLocalData(user: nil)
                                userSettings.loadLocalSettings(user: curUserContainer.curUser)
                                categoryContainer.loadLocalCategories()
                            }
                        } label: {
                            Text("Sign Out")
                                .bold()
                        }
                    } else {
                        Button {
                            showLoginView = true
                        } label: {
                            Text("Log In")
                                .bold()
                        }
                        .sheet(isPresented: $showLoginView) {
                            LogInView(showLoginView: $showLoginView)
                        }
                        
                    }
                }
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
                .padding(.horizontal)
                Toggle(isOn: $userSettings.showKeyboardOnStart) {
                    Text("Keyboard On New Task")
                }
                .onChange(of: userSettings.showKeyboardOnStart) { newValue in
                    userSettings.showKeyboardOnStart = newValue
                    userSettings.saveLocalSettings()
                    if curUserContainer.curUser != nil {
                        FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                    }
                }
                .padding(.horizontal)
                Toggle(isOn: $userSettings.taskLayover) {
                    Text("Task Layover")
                }
                .onChange(of: userSettings.taskLayover) { newValue in
                    userSettings.taskLayover = newValue
                    userSettings.saveLocalSettings()
                    if curUserContainer.curUser != nil {
                        FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                    }
                }
                .padding(.horizontal)
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
    func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            return true
        } catch let signOutError_ as NSError {
            print("Error signing out")
            return false
        }
    }
}

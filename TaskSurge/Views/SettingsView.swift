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
    @EnvironmentObject var lastModifiedTimeContainer: LastModifiedTime
    @EnvironmentObject var lastModifiedByContainer: LastModifiedBy
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
                .padding([.top, .leading])
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
//                HStack {
//                    if curUserContainer.curUser == nil {
//                        Image(systemName: "person.circle")
//                            .font(.system(size: 40))
//                            .padding(.leading)
//                    }
//                    if curUserContainer.curUser != nil {
//                        Text("\(curUserContainer.userName)")
//                            .font(.system(size: 25))
//                            .bold()
//                            .padding(.leading)
//                        Spacer()
//                        Button {
//                            if signOut() {
//                                curUserContainer.curUser = nil
//                                todoListContainer.loadLocalData(user: nil)
//                                userSettings.loadLocalSettings(user: nil)
//                                categoryContainer.loadLocalCategories()
//                            }
//                        } label: {
//                            Text("Sign Out")
//                                .bold()
//                        }
//                        .padding()
//                    } else {
//                        Spacer()
//                        Button {
//                            showLoginView = true
//                        } label: {
//                            Text("Log In")
//                                .bold()
//                                .padding()
//                        }
//                        .sheet(isPresented: $showLoginView) {
//                            LogInView(showLoginView: $showLoginView)
//                        }
//                        
//                    }
//                }
//                
                Divider()
                
                VStack {
                    Toggle(isOn: $userSettings.darkMode) {
                        Text("Dark Mode")
                    }
                    .onChange(of: userSettings.darkMode) { newValue in
                        userSettings.darkMode = newValue
                        updateLastModifiedTimeAndBy()
                        userSettings.saveLocalSettings()
                        if curUserContainer.curUser != nil {
                            FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                        }
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                VStack {
                    Toggle(isOn: $userSettings.showKeyboardOnStart) {
                        Text("Keyboard Auto-Focus")
                    }
                    .onChange(of: userSettings.showKeyboardOnStart) { newValue in
                        userSettings.showKeyboardOnStart = newValue
                        updateLastModifiedTimeAndBy()
                        userSettings.saveLocalSettings()
                        if curUserContainer.curUser != nil {
                            FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                        }
                    }
                    
                    HStack {
                        Text("Show keyboard on new task creation")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                VStack {
                    Toggle(isOn: $userSettings.taskLayover) {
                        Text("Task Layover")
                    }
                    .onChange(of: userSettings.taskLayover) { newValue in
                        userSettings.taskLayover = newValue
                        moveLayoverItems()
                        updateLastModifiedTimeAndBy()
                        userSettings.saveLocalSettings()
                        if curUserContainer.curUser != nil {
                            FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                        }
                    }
                    HStack {
                        Text("Incomplete tasks from the previous day are moved to the current date")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                VStack {
                    Toggle(isOn: $userSettings.showCalendarButton) {
                        Text("Calendar Guidance Button")
                    }
                    .onChange(of: userSettings.showCalendarButton) { newValue in
                        userSettings.showCalendarButton = newValue
                        userSettings.saveLocalSettings()
                        updateLastModifiedTimeAndBy()
                        if curUserContainer.curUser != nil {
                            FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                        }
                    }
                    HStack {
                        Text("Show Calendar Movement Buttons")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
                .padding(.horizontal)
                Divider()
                VStack {
                    Toggle(isOn: $userSettings.showProgressBar) {
                        Text("Progress Bar")
                    }
                    .onChange(of: userSettings.showProgressBar) { newValue in
                        withAnimation(.easeInOut) {
                            userSettings.showProgressBar = newValue
                            if userSettings.circularProgressBar {
                                userSettings.circularProgressBar = false
                            }
                        }
                        updateLastModifiedTimeAndBy()
                        userSettings.saveLocalSettings()
                        if curUserContainer.curUser != nil {
                            FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                        }
                    }
                }
                .padding(.horizontal)
                Divider()
                VStack {
                    Toggle(isOn: $userSettings.circularProgressBar) {
                        Text("Circular Progress Bar")
                    }
                    .onChange(of: userSettings.circularProgressBar) { newValue in
                        userSettings.circularProgressBar = newValue
                        userSettings.saveLocalSettings()
                        updateLastModifiedTimeAndBy()
                        if curUserContainer.curUser != nil {
                            FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                        }
                    }
                    .disabled(!userSettings.showProgressBar)
                    
                }
                .padding(.horizontal)
                Divider()
                VStack {
                    Toggle(isOn: $userSettings.coloredProgressBar) {
                        Text("High Contrast Progress Bar")
                    }
                    .onChange(of: userSettings.coloredProgressBar) { newValue in
                        userSettings.coloredProgressBar = newValue
                        userSettings.saveLocalSettings()
                        updateLastModifiedTimeAndBy()
                        if curUserContainer.curUser != nil {
                            FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                        }
                    }
                    .disabled(!userSettings.showProgressBar)
                }
                .padding(.horizontal)
                Divider()
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
                .padding(.vertical)
            }
        }
        
    }
    
    func taskLayoverExist(todoContent: TodoContent) -> Bool {
        if !userSettings.taskLayover {
            return false
        }
        return sameDate(date1: curUserContainer.lastActiveDate, date2: todoContent.date) && !sameDate(date1: Date(), date2: curUserContainer.lastActiveDate) && !todoContent.completed
    }
    
    func sameDate(date1: Date, date2: Date) -> Bool {
        return Calendar.current.compare(date1, to: date2, toGranularity: .day) == .orderedSame
    }
    
    func moveLayoverItems() {
        for i in todoListContainer.todoList.indices {
            if taskLayoverExist(todoContent: todoListContainer.todoList[i]) {
                todoListContainer.todoList[i].date = Date()
            }
        }
        saveData()
    }
    
    func saveData() {
        todoListContainer.saveLocalData()
        if curUserContainer.curUser != nil {
            updateLastModifiedTimeAndBy()
            FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
        }
    }
    
    func updateLastModifiedTimeAndBy() {
        lastModifiedTimeContainer.lastModifiedTime = Date()
        lastModifiedTimeContainer.saveData()
        lastModifiedByContainer.saveData()
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

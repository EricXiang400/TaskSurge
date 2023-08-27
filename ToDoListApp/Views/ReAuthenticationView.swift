//
//  ReAuthenticationView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 8/26/23.
//

import Foundation
import Firebase
import SwiftUI
import FirebaseAuth

struct ReAuthenticationView: View {
    @EnvironmentObject var curUserContainer: AppUser
    @EnvironmentObject private var todoListContainer: TodoList
    @Binding var showReauthenticationView: Bool
    @State var email: String = ""
    @State var password: String = ""
    @State private var error: Error? = nil
    @State var showForgotPasswordView: Bool = false
    @EnvironmentObject var userSettings: UserSettings
    @Binding var isShowingSetting: Bool
    var body: some View {
        VStack {
            Text("Re-Authenticate")
                .font(.title)
                .bold()
            VStack {
                Text("Log in again to verify your identity")
                    .font(.custom("", size: 13))
                TextField("Email", text: $email)
                    .textFieldStyle(CustomTextFieldStyle())
                    .frame(width: UIScreen.main.bounds.width * 0.85)
                SecureField("Password", text: $password)
                    .textFieldStyle(CustomTextFieldStyle())
                    .frame(width: UIScreen.main.bounds.width * 0.85)
                HStack {
                    if let loginError = error {
                        Text(loginError.localizedDescription)
                            .foregroundColor(.red)
                            .padding(.leading, UIScreen.main.bounds.width * 0.075)
                            .font(.system(size: 13))
                    }
                    Spacer()
                }
            }
            
            Button(action: {
                reAuthenticate(email: email, password: password) {
                    userDataDeletion {
                        userAccountDeletion {
                            deleteLocalData()
                            if signOut() {
                                curUserContainer.curUser = nil
                                todoListContainer.todoList = []
                                userSettings.loadLocalSettings(user: curUserContainer.curUser)
                                isShowingSetting = false
                            }
                            
                        }
                    }
                }
            }) {
                if email == "" || password == "" {
                    Text("Authenticate")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .background(Color.blue.opacity(0.5))
                        .cornerRadius(8)
                } else {
                    Text("Authenticate")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .disabled(email == "" || password == "")
            
            VStack {
                HStack {
                    Button("Forgot Password?") {
                        showForgotPasswordView = true
                    }
                    .padding(.leading)
                    .sheet(isPresented: $showForgotPasswordView) {
                        ForgotPasswordView(showForgotPasswordView: $showForgotPasswordView)
                    }
                    Spacer()
                }
            }
            .padding()
        }
        .padding(5)
    }
    func reAuthenticate(email: String, password: String, completion: @escaping () -> Void) {
        let user = curUserContainer.curUser
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        user?.reauthenticate(with: credential) { authResult, error in
            if let error = error {
                print("Error in reauthentication")
                self.error = error
                return
            }
            completion()
        }
    }
    
    func userDataDeletion(completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let userID = Auth.auth().currentUser?.uid
        db.collection("users").document(userID!).delete() { err in
            if let err = err {
                print("Error deleting user data \(err)")
            } else {
                completion()
            }
        }
    }
    
    func userAccountDeletion(completion: @escaping () -> Void) {
        let user = Auth.auth().currentUser
        user?.delete { error in
            if let error = error {
                print("Error deleting user: \(error)")
            } else {
                completion()
            }
        }
    }
    
    func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            showReauthenticationView = false
            return true
        } catch let signOutError_ as NSError {
            print("Error signing out")
            return false
        }
    }
    
    func deleteLocalData() {
        let fileManager = FileManager.default
        let curUser = curUserContainer.curUser
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to access document directory when deleting local user data")
            return
        }
        let categoryFileURL = documentsURL.appendingPathComponent("\(curUser!.uid)-categories.json")
        let settingsFileURL = documentsURL.appendingPathComponent("\(curUser!.uid)-settings.json")
        let userFileURL = documentsURL.appendingPathComponent("\(curUser!.uid)-user.json")
        let dataFileURL = documentsURL.appendingPathComponent("\(curUser!.uid)-data.json")
        do {
            try fileManager.removeItem(at: categoryFileURL)
            try fileManager.removeItem(at: settingsFileURL)
            try fileManager.removeItem(at: userFileURL)
            try fileManager.removeItem(at: dataFileURL)
            print("user local data success")
        } catch {
            print("Error deleting user local data: \(error.localizedDescription)")
        }
    }
    
}

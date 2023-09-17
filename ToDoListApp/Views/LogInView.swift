//
//  LogInView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 6/7/23.
//

import Foundation
import Firebase
import SwiftUI

struct LogInView: View {
    @EnvironmentObject var curUserContainer: AppUser
    @EnvironmentObject private var todoListContainer: TodoList
    @EnvironmentObject private var categoryContainer: CategoriesData
    @Binding var showLoginView: Bool
    @State var showSignupView = false
    @State var email: String = ""
    @State var password: String = ""
    @State private var error: Error? = nil
    @State var showForgotPasswordView: Bool = false
    @EnvironmentObject var userSettings: UserSettings
    var body: some View {
        VStack {
            Text("Log In")
                .font(.title)
                .bold()
            VStack {
                Text("Log in to share your data across your devices")
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
                login(completion: {
                    todoListContainer.loadLocalData(user: curUserContainer.curUser!)
                    userSettings.loadLocalSettings(user: curUserContainer.curUser)
                    categoryContainer.loadLocalCategories()
                    showLoginView = false
                    print("ALL OPERATION FINISHED")
                })
            }) {
                if email == "" || password == "" {
                    Text("Sign in")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .background(Color.blue.opacity(0.5))
                        .cornerRadius(8)
                } else {
                    Text("Sign in")
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
                    Text("New User?")
                        .padding(.leading)
                    Button("Sign Up") {
                        showSignupView = true
                    }
                    .sheet(isPresented: $showSignupView) {
                        SignUpView(showLoginView: $showLoginView)
                    }
                    Spacer()
                }
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
    
    func login(completion: @escaping () -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("\(error.localizedDescription)")
                self.error = error
            } else {
                print("Sign-in success")
                curUserContainer.curUser = Auth.auth().currentUser!
                FireStoreManager.firestoreToLocal(uid: Auth.auth().currentUser!.uid) {
                    completion()
                    
                }
            }
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
            )
            .foregroundColor(.primary)
    }
}

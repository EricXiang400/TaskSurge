//
//  SignUpView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 6/7/23.
//

import Foundation
import Firebase
import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var curUserContainer: AppUser
    @EnvironmentObject private var todoListContainer: TodoList
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var categoryContainer: CategoriesData
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @Binding var showLoginView: Bool
    @State var username: String = ""
    @State private var isChecked: Bool = false
    @State private var error: Error?
    var body: some View {
        VStack {
            Text("Sign Up")
                .font(.title)
                .bold()
            TextField("Enter Username Here", text: $username)
                .textFieldStyle(CustomTextFieldStyle())
                .frame(width: UIScreen.main.bounds.width * 0.85)
            TextField("Enter Email Here", text: $email)
                .textFieldStyle(CustomTextFieldStyle())
                .frame(width: UIScreen.main.bounds.width * 0.85)
            SecureField("Enter Password Here", text: $password)
                .textFieldStyle(CustomTextFieldStyle())
                .frame(width: UIScreen.main.bounds.width * 0.85)
            SecureField("Re-Enter Password Here", text: $confirmPassword)
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
            HStack {
                Button (action: {
                    isChecked.toggle()
                }) {
                    Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(isChecked ? .blue : .gray)
                }
                .padding(.leading)
                Text("By clicking this checkmark, you agree to our terms and conditions")
                    .font(.custom("", size: 13))
                    .padding()
            }
            Button(action: {
                signUp()
            }) {
                if email == "" || password == "" || confirmPassword == "" || username == "" || !isChecked {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .background(Color.blue.opacity(0.5))
                        .cornerRadius(8)
                } else {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
        }
        .padding(5)
    }
    
    func signUp() {
        if password != confirmPassword || (confirmPassword == "") {
            print("Password and confirm password does not match")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                self.error = error
                return
            }
            guard let user = result?.user else {
                print("Sign-up Error2")
                return
            }
            showLoginView = false
            curUserContainer.saveLocalUser(user: user, userName: username)
            UserSettings().saveLocalSettings()
            TodoList().saveLocalData()
            CategoriesData().saveLocalCategories()
            FireStoreManager.localToFirestore(uid: user.uid)
        }
    }
}


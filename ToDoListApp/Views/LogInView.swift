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
    @Binding var showLoginView: Bool
    @State var showSignupView = false
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("Email:")
                TextField("Email", text: $email)
            }
            HStack {
                Text("Password")
                SecureField("Password", text: $password)
            }
            Button(action: {
                login(completion: {
                    todoListContainer.todoList = TodoList.loadLocalData(user: curUserContainer.curUser!)
                    showLoginView = false
                })
            }) {
                Text("Sign in")
            }
            Button("Sign Up") {
                showSignupView = true
            }
            .sheet(isPresented: $showSignupView) {
                SignUpView(showLoginView: $showLoginView)
            }
        }
        .padding(5)
    }
    
    func login(completion: @escaping () -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                print("Sign-in success")
                curUserContainer.curUser = Auth.auth().currentUser!
                FireStoreManager.firestoreToLocal(uid: Auth.auth().currentUser!.uid) {
                    completion()
                    print("ALL OPERATION FINISHED")
                }
                
            }
        }
    }
}

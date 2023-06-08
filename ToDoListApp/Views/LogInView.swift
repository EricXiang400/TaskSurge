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
    @State var showSignupView = false
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("Email:")
                TextField("Email", text:$email)
            }
            HStack {
                Text("Password")
                SecureField("Password", text: $password)
            }
            
            Button(action: {login()}) {
                Text("Sign in")
            }
            Button("Sign Up") {
                showSignupView = true
            }
            .sheet(isPresented: $showSignupView) {
                SignUpView()
            }
            
        }
        .padding(5)
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                print("Sign-up success")
            }
        }
    }
    
}

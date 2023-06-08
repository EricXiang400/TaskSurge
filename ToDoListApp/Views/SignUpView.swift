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
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    var body: some View {
        VStack {
            TextField("Email", text:$email)
            SecureField("Password", text: $password)
            SecureField("Confirm Password", text: $confirmPassword)
            Button(action: {signUp()}) {
                Text("Sign Up")
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
                print("Sign-up Error")
            } else {
                print("Sign-up success")
            }
        }
    }
}

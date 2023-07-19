//
//  ForgotPasswordView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 7/17/23.
//

import SwiftUI
import Firebase

struct ForgotPasswordView: View {
    @State private var email: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @Binding var showForgotPasswordView: Bool
    var body: some View {
        VStack {
            Text("Enter Your Email")
                .font(.title)
                .bold()
            TextField("Email", text: $email)
                .textFieldStyle(CustomTextFieldStyle())
                .frame(width: UIScreen.main.bounds.width * 0.85)
            
            Button (action: {
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if let error = error {
                        alertMessage = error.localizedDescription
                    } else {
                        alertMessage = "Password reset email sent successfully."
                        showForgotPasswordView = false
                    }
                    showAlert = true
                }
            }) {
                if email == "" {
                    Text("Reset Password")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .background(Color.blue.opacity(0.5))
                        .cornerRadius(8)
                } else {
                    Text("Reset Password")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }

            }
            .disabled(email == "")
            .padding()
        }
    }
}

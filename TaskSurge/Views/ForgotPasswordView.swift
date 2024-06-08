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
    @State private var resetError: Error? = nil
    
    var body: some View {
        VStack {
            Text("Enter Your Email")
                .font(.title)
                .bold()
            TextField("Email", text: $email)
                .textFieldStyle(CustomTextFieldStyle())
                .frame(width: UIScreen.main.bounds.width * 0.85)
            HStack {
                if let error = resetError {
                    Text("\(error.localizedDescription)")
                        .foregroundColor(.red)
                        .padding(.leading, UIScreen.main.bounds.width * 0.075)
                        .font(.system(size: 13))
                    Spacer()
                }
            }
            Button (action: {
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if let error = error {
                        resetError = error
                    } else {
                        alertMessage = "Password reset email sent successfully."
                    }
                    showAlert = true
                }
            }) {
                if email == "" {
                    Text("Get Reset Password Link")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .background(Color.blue.opacity(0.5))
                        .cornerRadius(8)
                } else {
                    Text("Get Reset Password Link")
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

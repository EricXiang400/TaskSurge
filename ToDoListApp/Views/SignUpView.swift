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
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @Binding var showLoginView: Bool
    @State var username: String = ""
    var body: some View {
        VStack {
            HStack {
                Text("Username")
                TextField("Enter Username Here", text: $username)
            }
            HStack {
                Text("Email")
                TextField("Enter Email Here", text: $email)
            }
            HStack {
                Text("Password")
                SecureField("Enter Password Here", text: $password)
            }
            HStack {
                Text("Confirm Password")
                SecureField("Enter Password Here", text: $confirmPassword)
            }
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
                return
            }
            guard let user = result?.user else {
                print("Sign-up Error2")
                return
            }
            showLoginView = false
            let db = Firestore.firestore()
            let userDocumentRef = db.collection("uid").document(user.uid)
            let jsonEncoder = JSONEncoder()
            do {
                let encodedData = try jsonEncoder.encode([] as! [TodoContent])
                let user = UserWrapper(uid: result!.user.uid, userName: username)
                let encodedUser = try jsonEncoder.encode(user)
                userDocumentRef.setData(["user": encodedUser,"data": encodedData])
                print("Sign-up success")
            } catch {
                print("Encode empty array into json error")
            }
            
        }
    }
}

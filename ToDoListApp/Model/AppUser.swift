//
//  User.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 6/9/23.
//

import Foundation
import Firebase

final class AppUser: ObservableObject {
    @Published var curUser: User? = Auth.auth().currentUser
}

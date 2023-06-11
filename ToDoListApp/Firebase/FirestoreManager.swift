//
//  FirestoreManager.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 6/9/23.
//

import Foundation
import Firebase

class FireStoreManager: ObservableObject {
    static func uploadData(uid: String, todoList: [TodoContent]) {
        let db = Firestore.firestore()
        let docRef = db.collection("UID").document(uid)
        docRef.updateData(["UID": uid, "TodoList": todoList]) { error in
            if error != nil {
                print("Error uploading data")
            } else {
                print("Data upload success")
            }
        }
    }
}

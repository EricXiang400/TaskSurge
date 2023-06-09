//
//  FirestoreManager.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 6/9/23.
//

import Foundation
import Firebase

class FireStoreManager: ObservableObject {
    func createUser(userName: String) {
        let db = Firestore.firestore()
        let docRef = db.collection("UID").document(userName)
//        docRef.setData(data) { error in
//            
//        }
    }
}

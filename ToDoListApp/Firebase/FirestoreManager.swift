//
//  FirestoreManager.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 6/9/23.
//

import Foundation
import Firebase

class FireStoreManager: ObservableObject {
    
    static func localToFirestore(uid: String) {
        guard let currentUser = Auth.auth().currentUser else {
            print("Need to be logged in")
            return
        }
        let db = Firestore.firestore()
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent("\(uid)-data.json")
        do {
            let encodedData = try Data(contentsOf: fileURL)
//            let decoder = JSONDecoder()
//            let decodedData = try decoder.decode([TodoContent].self, from: data)
            let userDocumentRef = db.collection("uid").document(uid)
            userDocumentRef.setData(["data": encodedData], merge: true) { error in
                if error != nil {
                    print("Error transfering data")
                } else {
                    print("Data upload success")
                }
            }
        } catch {
            print("Error reading data from document directory")
        }
    }
    static func firestoreToLocal(uid: String) {
        
    }
    
}

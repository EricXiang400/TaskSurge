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
        let collectionReference = Firestore.firestore().collection("uid")
        let documentRef = collectionReference.document("\(uid)")
        documentRef.getDocument { document, error in
            if error != nil {
                print("Error listening for doc changes")
            }
            guard let document = document else {
                print("Doc does not exist")
                return
            }
            if let encodedData = document.data() {
                do {
                    let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    let fileURL = documentDirectory.appendingPathComponent("\(uid)-data.json")
                    if let jsonData = encodedData["data"] {
                        try (jsonData as! Data).write(to: fileURL)
                        print("Data download success")
                    } else {
                        print("Data field is empty")
                    }
                    
                } catch {
                    print("Error when working with encoded data from cloud")
                }
            }
            
            
        }
    }
    
}

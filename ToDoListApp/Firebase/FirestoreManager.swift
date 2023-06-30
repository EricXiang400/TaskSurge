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
        let dataFileURL = documentDirectory.appendingPathComponent("\(uid)-data.json")
        let userFileURL = documentDirectory.appendingPathComponent("\(uid)-user.json")
        do {
            let encodedUser = try Data(contentsOf: userFileURL)
            let encodedData = try Data(contentsOf: dataFileURL)
            let userDocumentRef = db.collection("uid").document(uid)
            userDocumentRef.setData(["user": encodedUser,"data": encodedData], merge: true) { error in
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
    static func firestoreToLocal(uid: String, completion: @escaping () -> Void) {
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
                    let dataFileURL = documentDirectory.appendingPathComponent("\(uid)-data.json")
                    let userFileURL = documentDirectory.appendingPathComponent("\(uid)-user.json")
                    print(userFileURL)
                    if let userJsonData = encodedData["user"] {
                        try (userJsonData as! Data).write(to: userFileURL)
                        print("user data download success")
                    } else {
                        print("User information field is empty")
                    }
                    if let dataJsonData = encodedData["data"] {
                        try (dataJsonData as! Data).write(to: dataFileURL)
                        print("Content data download success")
                    } else {
                        print("Data field is empty")
                    }
                } catch {
                    print("Error when working with encoded data from cloud")
                }
            }
            completion()
        }
    }
}

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
        let settingsFileURL = documentDirectory.appendingPathComponent("\(uid)-settings.json")
        let categoriesFileURL = documentDirectory.appendingPathComponent("\(uid)-categories.json")
        let categoryFileURL = documentDirectory.appendingPathComponent("\(uid)-category.json")
        do {
            let encodedUser = try Data(contentsOf: userFileURL)
            let encodedData = try Data(contentsOf: dataFileURL)
            let encodedSettings = try Data(contentsOf: settingsFileURL)
            let encodedCategories = try Data(contentsOf: categoriesFileURL)
            let encodedCategory = try Data(contentsOf: categoryFileURL)
            let userDocumentRef = db.collection("uid").document(uid)
            userDocumentRef.setData(["user": encodedUser,"data": encodedData, "settings": encodedSettings,"categories": encodedCategories, "category": encodedCategory], merge: true) { error in
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
                    let settingsFileURL = documentDirectory.appendingPathComponent("\(uid)-settings.json")
                    let categoriesFileURL = documentDirectory.appendingPathComponent("\(uid)-categories.json")
                    let categoryFileURL = documentDirectory.appendingPathComponent("\(uid)-category.json")
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
                    if let settingsJsonData = encodedData["settings"] {
                        try (settingsJsonData as! Data).write(to: settingsFileURL)
                        print("Settings data download success")
                    } else {
                        print("setting field is empty")
                    }
                    if let categoriesJsonData = encodedData["categories"] {
                        try (categoriesJsonData as! Data).write(to: categoriesFileURL)
                        print("categories data download success")
                    } else {
                        print("categoreis field is empty")
                    }
                    if let categoryJsonData = encodedData["category"] {
                        try (categoryJsonData as! Data).write(to: categoryFileURL)
                        print("category data download success")
                    } else {
                        print("category data field is empty")
                    }
                } catch {
                    print("Error when working with encoded data from cloud")
                }
            }
            completion()
        }
    }
}

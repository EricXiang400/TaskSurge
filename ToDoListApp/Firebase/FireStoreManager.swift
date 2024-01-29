//
//  FirestoreManager.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 6/9/23.
//

import Foundation
import Firebase

class FireStoreManager: ObservableObject {
    static var dataJustSent: Bool = false
    
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
        let lastModifiedTimeFileURL = documentDirectory.appendingPathComponent("\(uid)-lastModifiedTime.json")
        do {
            let encodedLastModifiedTime = try Data(contentsOf: lastModifiedTimeFileURL)
            guard let lastModifiedTimeDict = try? JSONSerialization.jsonObject(with: encodedLastModifiedTime, options: .mutableContainers) as? [String : Any] else {
                print("Could not serialize LastModifiedTime")
                return
            }
            let encodedUser = try Data(contentsOf: userFileURL)
            guard let userDict = try? JSONSerialization.jsonObject(with: encodedUser, options: .mutableContainers) as? [String : Any] else {
                print("Could not serialize user dict")
                return
            }
            let encodedData = try Data(contentsOf: dataFileURL)
            guard let dataDict = try? JSONSerialization.jsonObject(with: encodedData, options: .mutableContainers) as? [String:Any] else {
                print("Could not serialize data dict")
                return
            }
            let encodedSettings = try Data(contentsOf: settingsFileURL)
            guard let settingsDict = try? JSONSerialization.jsonObject(with: encodedSettings, options: .mutableContainers) as? [String : Any] else {
                print("Could not serialize setting dict")
                return
            }
            let encodedCategories = try Data(contentsOf: categoriesFileURL)
            guard let categoriesDict = try? JSONSerialization.jsonObject(with: encodedCategories, options: .mutableContainers) as? [String : Any] else {
                print("Could not serialize categories dict")
                return
            }
            let encodedCategory = try Data(contentsOf: categoryFileURL)
            guard let categoryDict = try? JSONSerialization.jsonObject(with: encodedCategory, options: .mutableContainers) as? [String : Any] else {
                print("Could not serialize category dict")
                return
            }
            dataJustSent = true
            let userDocumentRef = db.collection("uid").document(uid)
            userDocumentRef.setData(["user": userDict,
                                     "data": dataDict,
                                     "settings": settingsDict,
                                     "categories": categoriesDict,
                                     "lastModifiedTime": lastModifiedTimeDict,
                                     "category": categoryDict], merge: true) { error in
                if error != nil {
                    print("Error transfering data")
                    fatalError()
                } else {
                    print("Data upload success")
                }
            }
        } catch {
            fatalError("Error writing data into firestore")
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
                    let lastModifiedTimeFileURL = documentDirectory.appendingPathComponent("\(uid)-lastModifiedTime.json")
                    if let lastModifiedTimeJsonDictData = encodedData["lastModifiedTime"] {
                        let lastModifiedTimeJsonData = try JSONSerialization.data(withJSONObject: lastModifiedTimeJsonDictData)
                        try lastModifiedTimeJsonData.write(to: lastModifiedTimeFileURL)
                        print("LastModifiedTime download success")
                    } else {
                        print("LastModifiedTime field is empty")
                    }
                    if let userJsonDictData = encodedData["user"] {
                        let userJsonData = try JSONSerialization.data(withJSONObject: userJsonDictData)
                        try userJsonData.write(to: userFileURL)
                        print("user data download success")
                    } else {
                        print("User information field is empty")
                    }
                    if let dataJsonDictData = encodedData["data"] {
                        let dataJsonData = try JSONSerialization.data(withJSONObject: dataJsonDictData)
                        try dataJsonData.write(to: dataFileURL)
                        print("Content data download success")
                    } else {
                        print("Data field is empty")
                    }
                    if let settingsJsonDictData = encodedData["settings"] {
                        let settingsJsonData = try JSONSerialization.data(withJSONObject: settingsJsonDictData)
                        try settingsJsonData.write(to: settingsFileURL)
                        print("Settings data download success")
                    } else {
                        print("setting field is empty")
                    }
                    if let categoriesJsonDictData = encodedData["categories"] {
                        let categoriesJsonData = try JSONSerialization.data(withJSONObject: categoriesJsonDictData)
                        try categoriesJsonData.write(to: categoriesFileURL)
                        print("categories data download success")
                    } else {
                        print("categoreis field is empty")
                    }
                    if let categoryJsonDictData = encodedData["category"] {
                        let categoryJsonData = try JSONSerialization.data(withJSONObject: categoryJsonDictData)
                        try categoryJsonData.write(to: categoryFileURL)
                        print("category data download success")
                    } else {
                        print("category data field is empty")
                    }
                    completion()
                } catch {
                    fatalError("Error when working with encoded data from cloud")
                }
            }
        }
    }
}

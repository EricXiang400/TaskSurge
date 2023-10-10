//
//  UserSettings.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 7/27/23.
//

import Foundation
import Firebase
import FirebaseAuth

final class UserSettings: NSObject, ObservableObject, Codable {
    @Published var sortOption: Bool
    @Published var darkMode: Bool
    @Published var weekView: Bool
    @Published var taskLayover: Bool
    @Published var showKeyboardOnStart: Bool
    @Published var showCalendarButton: Bool
    @Published var showProgressBar: Bool
    @Published var circularProgressBar: Bool
    @Published var coloredProgressBar: Bool
    
    init(sortOption: Bool = false, darkMode: Bool = false, weekView: Bool = false, taskLayover: Bool = false, showKeyboardOnStart: Bool = true, showCalendarButton: Bool = true, showProgressBar: Bool = false, circularProgressBar: Bool = false, coloredProgressbar: Bool = false) {
        self.sortOption = sortOption
        self.darkMode = darkMode
        self.weekView = weekView
        self.taskLayover = taskLayover
        self.showKeyboardOnStart = showKeyboardOnStart
        self.showCalendarButton = showCalendarButton
        self.showProgressBar = showProgressBar
        self.circularProgressBar = circularProgressBar
        self.coloredProgressBar = coloredProgressbar
    }
    
    enum CodingKeys: CodingKey {
        case sortOption
        case darkMode
        case weekView
        case taskLayover
        case showKeyboardOnStart
        case showCalendarButton
        case showProgressBar
        case circularProgressBar
        case coloredProgressBar
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sortOption, forKey: .sortOption)
        try container.encode(darkMode, forKey: .darkMode)
        try container.encode(weekView, forKey: .weekView)
        try container.encode(taskLayover, forKey: .taskLayover)
        try container.encode(showKeyboardOnStart, forKey: .showKeyboardOnStart)
        try container.encode(showCalendarButton, forKey: .showCalendarButton)
        try container.encode(showProgressBar, forKey: .showProgressBar)
        try container.encode(circularProgressBar, forKey: .circularProgressBar)
        try container.encode(coloredProgressBar, forKey: .coloredProgressBar)
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let sortOption = try container.decode(Bool.self, forKey: .sortOption)
        let darkMode = try container.decode(Bool.self, forKey: .darkMode)
        let weekView = try container.decode(Bool.self, forKey: .weekView)
        let taskLayover = try container.decode(Bool.self, forKey: .taskLayover)
        let showKeyboardOnStart = try container.decode(Bool.self, forKey: .showKeyboardOnStart)
        let showCalendarButton = try container.decode(Bool.self, forKey: .showCalendarButton)
        let showProgressbar = try container.decode(Bool.self, forKey: .showProgressBar)
        let circularProgressBar = try container.decode(Bool.self, forKey: .circularProgressBar)
        let coloredProgressBar = try container.decode(Bool.self, forKey: .coloredProgressBar)
        self.init(sortOption: sortOption, darkMode: darkMode, weekView: weekView, taskLayover: taskLayover, showKeyboardOnStart: showKeyboardOnStart, showCalendarButton: showCalendarButton, showProgressBar: showProgressbar, circularProgressBar: circularProgressBar, coloredProgressbar: coloredProgressBar)
    }
    
    func loadLocalSettings(user: User?) {
        let data: Data
        let fileURL: URL
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let curUser = user {
                fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-settings.json")
            } else {
                fileURL = documentDirectory.appendingPathComponent("settings.json")
            }
            data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let output = try decoder.decode(UserSettings.self, from: data)
            self.sortOption = output.sortOption
            self.darkMode = output.darkMode
            self.weekView = output.weekView
            self.taskLayover = output.taskLayover
            self.showKeyboardOnStart = output.showKeyboardOnStart
            self.showCalendarButton = output.showCalendarButton
            self.showProgressBar = output.showProgressBar
            self.circularProgressBar = output.circularProgressBar
            self.coloredProgressBar = output.coloredProgressBar
        } catch {
            print("No local settings so return nil")
        }
    }
    
    func saveLocalSettings() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let curUser = Auth.auth().currentUser {
                let fileURL = documentDirectory.appendingPathComponent("\(curUser.uid)-settings.json")
                let encoder = JSONEncoder()
                let encodedData = try encoder.encode(self)
                try encodedData.write(to: fileURL)
                print("Settings saved successful")
            } else {
                let fileURL = documentDirectory.appendingPathComponent("settings.json")
                let encoder = JSONEncoder()
                let encodedData = try encoder.encode(self)
                try encodedData.write(to: fileURL)
                print("Settings saved successful")
            }
        } catch {
            fatalError("Error encoding or writing settings to storage")
        }
    }
}

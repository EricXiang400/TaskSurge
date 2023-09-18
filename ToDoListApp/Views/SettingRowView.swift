//
//  SettingRowView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 9/17/23.
//

import Foundation
import SwiftUI

struct SettingRowView: View {
    @EnvironmentObject var curUserContainer: AppUser
    @EnvironmentObject private var todoListContainer: TodoList
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var categoryContainer: CategoriesData
    @Binding var curSettingName: String
    @Binding var curSettingToggle: Bool
    
    var body: some View {
        Toggle(isOn: $curSettingToggle) {
            Text(curSettingName)
        }
        .onChange(of: $curSettingToggle) { newValue in
            userSettings.darkMode = newValue
            userSettings.saveLocalSettings()
            if curUserContainer.curUser != nil {
                FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
            }
        }
        .padding(.horizontal)
    }
    
    
}

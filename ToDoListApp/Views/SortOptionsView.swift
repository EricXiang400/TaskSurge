//
//  SortOptionsView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 7/21/23.
//

import Foundation
import SwiftUI

struct SortOptionsView: View {
    @EnvironmentObject var curUserContainer: AppUser
    @EnvironmentObject private var todoListContainer: TodoList
    @EnvironmentObject private var userSettings: UserSettings
    @Environment(\.colorScheme) var colorScheme
    @Binding var showSortingOptions: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Sort By:")
                .font(.headline)
            VStack {
                Button(action: {
                    userSettings.sortOption = 1
                    showSortingOptions = false
                    todoListContainer.todoList.sort(by: {$0.progress < $1.progress})
                    todoListContainer.saveLocalData()
                    userSettings.saveLocalSettings()
                    if curUserContainer.curUser != nil {
                        FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                    }
                }) {
                    if userSettings.sortOption == 1 {
                        HStack {
                            Text("Progress")
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                            Spacer()
                        }
                    } else {
                        HStack {
                            Text("Progress")
                            Spacer()
                        }
                    }
                }
                .padding(.trailing, 10)
                .background(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                Divider()
                Button(action: {
                    userSettings.sortOption = 2
                    showSortingOptions = false
                    todoListContainer.saveLocalData()
                    userSettings.saveLocalSettings()
                    if curUserContainer.curUser != nil {
                        FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                    }
                }) {
                    if userSettings.sortOption == 2 {
                        HStack {
                            Text("None")
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                            Spacer()
                        }
                    } else {
                        HStack {
                            Text("None")
                            Spacer()
                        }
                    }
                }
                .padding(.trailing, 10)
                .background(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
            }
            .listStyle(.plain)
        }
        .padding()
        .background(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

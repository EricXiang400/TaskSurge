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
    @Binding var showSortingOptions: Bool
    var body: some View {
        VStack(alignment: .leading) {
            Text("Sort By:")
                .font(.headline)
            Button(action: {
                showSortingOptions = false
                todoListContainer.todoList.sort(by: {$1.date < $0.date})
                todoListContainer.saveLocalData()
                if curUserContainer.curUser != nil {
                    FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                }
                curUserContainer.sortOption = 0
            }) {
                if curUserContainer.sortOption == 0 {
                    HStack {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                        Text("Date")
                    }
                } else {
                    HStack {
                        Text("Date")
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.horizontal)
            Button(action: {
                showSortingOptions = false
                todoListContainer.todoList.sort(by: {$0.progress < $1.progress})
                todoListContainer.saveLocalData()
                if curUserContainer.curUser != nil {
                    FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                }
                curUserContainer.sortOption = 1
            }) {
                
                HStack {
                    if curUserContainer.sortOption == 1 {
                        
                    }
                }
                if curUserContainer.sortOption == 1 {
                    HStack {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                        Text("Progress")
                    }
                } else {
                    HStack {
                        Text("Progress")
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.horizontal)
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

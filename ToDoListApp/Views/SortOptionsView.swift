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
                .padding(.horizontal)
            Button(action: {
                showSortingOptions = false
                todoListContainer.todoList.sort(by: {$0.date < $1.date})
                todoListContainer.saveLocalData()
                if curUserContainer.curUser != nil {
                    FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                }
            }) {
                Text("Date")
            }
            .padding(.horizontal)
            Button(action: {
                showSortingOptions = false
                todoListContainer.todoList.sort(by: {$0.progress < $1.progress})
                todoListContainer.saveLocalData()
                if curUserContainer.curUser != nil {
                    FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                }
            }) {
                Text("Progress")
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

//
//  SortOptionsView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 7/21/23.
//

import Foundation
import SwiftUI

struct SortOptionsView: View {
    @Binding var selectedSortOption: Int
    @Binding var showSortingOptions: Bool
    var body: some View {
        VStack(alignment: .leading) {
            Text("Sort By:")
                .font(.headline)
                .padding(.horizontal)
            Button(action: {
                selectedSortOption = 1
                showSortingOptions = false
            }) {
                Text("Name")
            }
            .padding(.horizontal)
            Button(action: {
                selectedSortOption = 2
                showSortingOptions = false
            }) {
                Text("Date")
            }
            .padding(.horizontal)
            Button(action: {
                selectedSortOption = 3
                showSortingOptions = false
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

//
//  ModelData.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 6/1/23.
//

import Foundation

final class SelectedDate: ObservableObject {
    @Published var selectedDate: Date = Date()
}

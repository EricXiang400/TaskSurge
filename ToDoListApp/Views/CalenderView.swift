//
//  CalenderView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 5/30/23.
//

import Foundation
import SwiftUI

struct CalenderView : View {
    @EnvironmentObject var selectedDate: SelectedDate
    var body: some View {
        DatePicker(
            "Date",
            selection: $selectedDate.selectedDate,
            displayedComponents: [.date]
        )
        .datePickerStyle(.graphical)
    }
}

//
//  DateStructure.swift
//  TaskSurge
//
//  Created by Eric Xiang on 6/8/24.
//

import Foundation

struct DateStructure: Identifiable {
    let id = UUID()
    let date: Date
    let isCurrentMonth: Bool
    
    init(date: Date, isCurrentMonth: Bool) {
        self.date = date
        self.isCurrentMonth = isCurrentMonth
    }
}

extension DateStructure: Hashable {
    static func == (lhs: DateStructure, rhs: DateStructure) -> Bool {
        return lhs.date == rhs.date && lhs.isCurrentMonth == rhs.isCurrentMonth
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
    }
}

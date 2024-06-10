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
    let isNextMonth: Bool
    let isPrevMonth: Bool
    
    init(date: Date, isNextMonth: Bool, isPrevMonth: Bool) {
        self.date = date
        self.isNextMonth = isNextMonth
        self.isPrevMonth = isPrevMonth
    }
}

extension DateStructure: Hashable {
    static func == (lhs: DateStructure, rhs: DateStructure) -> Bool {
        return lhs.date == rhs.date && lhs.isPrevMonth == rhs.isPrevMonth && lhs.isNextMonth == lhs.isNextMonth
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
    }
}

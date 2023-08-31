//
//  CalenderView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 5/30/23.
//

import Foundation
import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var selectedDate: SelectedDate
    @State private var showOnlyCurrentWeek = false
    @State private var currentDate: Date = Date()
    
    private let monthArr: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    private let calendar = Calendar.current
    private var daysOfTheWeek: [String] = ["S", "M", "T", "W", "T", "F", "S"]
    
    private var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: currentDate) else { return [] }
        return range.map {
            calendar.date(byAdding: .day, value: $0 - 1, to: currentDate)!
        }
    }
    
    private var currentWeek: [Date] {
        guard let currentDay = calendar.dateComponents([.weekday], from: currentDate).weekday else { return [] }
        let startOfWeek = calendar.date(byAdding: .day, value: -currentDay + 1, to: currentDate)!
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: startOfWeek)
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("\(monthArr[calendar.component(.month, from: currentDate) - 1])-\(String(calendar.component(.year, from: currentDate)))")
                    .bold()
                Spacer()
                
                Spacer()
                Button(action: previousMonth) {
                    Image(systemName: "arrow.left.circle.fill")
                }
                Button(action: toggleView) {
                    Image(systemName: showOnlyCurrentWeek ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                }
                Button(action: nextMonth) {
                    Image(systemName: "arrow.right.circle.fill")
                }
            }
            .padding()
            .font(.title)
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            
            HStack(spacing: 15) {
                ForEach(daysOfTheWeek, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .bold()
                }
            }
            
            LazyVGrid(columns: columns) {
                ForEach(getAllDatesWithRollOverDates(date: currentDate), id: \.self) { day in
                    if selectedDate.selectedDate == day {
                        Text("\(calendar.component(.day, from: day))")
                            .frame(width: 30, height: 30)
                            .background(day == selectedDate.selectedDate ? Color.blue : Color.clear)
                            .clipShape(Circle())
                            .foregroundColor(day == selectedDate.selectedDate ? .white : .black)
                    } else {
                        Text("\(calendar.component(.day, from: day))")
                            .frame(width: 30, height: 30)
                            .background(day == selectedDate.selectedDate ? Color.blue : Color.clear)
                            .clipShape(Circle())
                            .onTapGesture {
                                selectedDate.selectedDate = day
                            }
                    }
                }
            }
        }
        .padding()
    }
    
    func splitIntoWeeks(dates: [Date]) -> [[Date]] {
        return stride(from: 0, to: dates.count, by: 7).map {
            Array(dates[$0 ..< min($0 + 7, dates.count)])
        }
    }
    
    func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
        }
    }
    
    func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
        }
    }
    
    func toggleView() {
        showOnlyCurrentWeek.toggle()
    }
    func getAllDates(date: Date) -> [Date] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: date) else { return [] }
        
        // Start of the month
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        
        let output: [Date] = range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
        return output
    }
    func getAllDatesWithRollOverDates(date: Date) -> [Date] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let firstWeekDay = calendar.component(.weekday, from: startOfMonth)
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: date)
        var output = getAllDates(date: date)
        var datesInLastMonth : [Date] = getAllDates(date: lastMonth!)
        let reverseDatesLastMonth = Array(datesInLastMonth.reversed())
        for i in 0..<firstWeekDay - 1 {
            output.insert(reverseDatesLastMonth[i], at: 0)
        }
        return output
    }
}

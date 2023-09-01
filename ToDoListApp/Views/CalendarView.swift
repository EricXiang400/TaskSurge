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
    @State private var offset = CGFloat.zero
    @State private var dragOffset = CGFloat.zero
    @State var dates: [Date] = []


    
    private let monthArr: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    private let calendar = Calendar.current
    private var daysOfTheWeek: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("\(monthArr[calendar.component(.month, from: currentDate) - 1])-\(String(calendar.component(.year, from: currentDate)))")
                    .bold()
                Spacer()
                
                Spacer()
                Button(action: {
//                    withAnimation(.easeInOut) {
                        if showOnlyCurrentWeek {
                            previousWeek()
                        } else {
                            previousMonth()
                        }
//                    }
                }) {
                    Image(systemName: "arrow.left.circle.fill")
                }
                Button {
                    withAnimation(.easeInOut) {
                        toggleView()
                    }
                } label: {
                    Image(systemName: showOnlyCurrentWeek ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                }
                Button(action: {
//                    withAnimation {
                        if showOnlyCurrentWeek {
                            nextWeek()
                        } else {
                            nextMonth()
                        }
//                    }
                }) {
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
                ForEach(showOnlyCurrentWeek ? getWeek(date: currentDate) : getAllDatesWithRollOverDates(date: currentDate), id: \.self) { day in
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
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        dragOffset = value.translation.width
                    })
                    .onEnded({ value in
                        withAnimation {
                            if dragOffset > 50 {
                                previousMonth()
                            } else if dragOffset < -50 {
                                nextMonth()
                            }
                            dragOffset = 0
                        }
                        
                    })
            )
        }
        .padding()
    }
    
    func getWeek(date: Date) -> [Date] {
        
        let datesInLastMonth = getAllDates(date: calendar.date(byAdding: .month, value: -1, to: date)!)
        let datesInNextMonth = getAllDates(date: calendar.date(byAdding: .month, value: 1, to: date)!)
        let datesInMonth = datesInLastMonth + getAllDates(date: date) + datesInNextMonth
        var index = datesInMonth.firstIndex(where: {
            let component1 = calendar.dateComponents([.month, .day], from: $0)
            let component2 = calendar.dateComponents([.month, .day], from: date)
            return component1.month == component2.month && component1.day == component2.day
        })!
        var output: [Date] = []
        let weekDay = calendar.component(.weekday, from: datesInMonth[index])
        output.append(datesInMonth[index])
        for i in 0..<weekDay-1 {
            output.insert(datesInMonth[index - i - 1], at: 0)
        }
        for i in weekDay+1..<8 {
            output.append(datesInMonth[index + i - weekDay])
        }
        return output
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
    
    func nextWeek() {
        if let newDate = calendar.date(byAdding: .day, value: +7, to: currentDate) {
            currentDate = newDate
        }
    }
    
    func previousWeek() {
        if let newDate = calendar.date(byAdding: .day, value: -7, to: currentDate) {
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

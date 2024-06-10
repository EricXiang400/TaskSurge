//
//  DateView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 10/10/23.
//

import Foundation
import SwiftUI

struct CalendarDayView: View {
    @EnvironmentObject var selectedDate: SelectedDate
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var curUserContainer: AppUser
    @State var offset = CGFloat.zero
    @State var dragOffsetH = CGFloat.zero
    @State var dragOffsetV = CGFloat.zero
    @State var dates: [DateStructure] = []
    
    @Binding var height: CGFloat
    
    var date: Date
    
    @Binding var tabViewIndex: Int
    let calendar = Calendar.current
    var body: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 7)
        ZStack {
            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(userSettings.weekView ? CalendarDayView.getWeek(date: date) : getAllDatesWithRollOverDates(date: date), id: \.id) { dayStruct in
                    var isCurrentMonth: Bool = dayStruct.isNextMonth == dayStruct.isPrevMonth
                    if CalendarWeekView.isSameDate(date1: selectedDate.selectedDate, date2: dayStruct.date) {
                        Text("\(calendar.component(.day, from: selectedDate.selectedDate))")
                            .frame(width: 25, height: 25)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .foregroundColor(.white)
                            .font(.headline)
                            .bold()
                    } else if CalendarWeekView.isSameDate(date1: Date(), date2: dayStruct.date) && isCurrentMonth {
                        Text("\(calendar.component(.day, from: Date()))")
                            .frame(width: 25, height: 25)
                            .background(Color.blue.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .foregroundColor(.white)
                            .font(.headline)
                            .opacity(isCurrentMonth || userSettings.weekView ? 1 : 0.5)
                            .onTapGesture {
                                selectedDate.selectedDate = dayStruct.date
                            }
                    } else {
                        Text("\(calendar.component(.day, from: dayStruct.date))")
                            .frame(width: 25, height: 25)
                            .background(Color.clear)
                            .opacity(isCurrentMonth || userSettings.weekView ? 1 : 0.5)
                            .onTapGesture {
                                selectedDate.selectedDate = dayStruct.date
                            }
                    }
                    
                }
            }
            
        }
    }
    
    static func getWeek(date: Date) -> [DateStructure] {
        let calendar = Calendar.current
        let datesInLastMonth = CalendarDayView.getAllDates(date: calendar.date(byAdding: .month, value: -1, to: date)!, isPrevMonth: true, isNextMonth: false)
        let datesInNextMonth = CalendarDayView.getAllDates(date: calendar.date(byAdding: .month, value: 1, to: date)!, isPrevMonth: false, isNextMonth: true)
        let datesInMonth = datesInLastMonth + CalendarDayView.getAllDates(date: date, isPrevMonth: false, isNextMonth: false) + datesInNextMonth
        let index = datesInMonth.firstIndex(where: {
            let component1 = calendar.dateComponents([.month, .day], from: $0.date)
            let component2 = calendar.dateComponents([.month, .day], from: date)
            return component1.month == component2.month && component1.day == component2.day
        })!
        var output: [DateStructure] = []
        let weekDay = calendar.component(.weekday, from: datesInMonth[index].date)
        output.append(datesInMonth[index])
        for i in 0..<weekDay-1 {
            output.insert(datesInMonth[index - i - 1], at: 0)
        }
        for i in weekDay+1..<8 {
            output.append(datesInMonth[index + i - weekDay])
        }
        return output
    }

    
    static func getAllDates(date: Date, isPrevMonth: Bool, isNextMonth: Bool) -> [DateStructure] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: date) else { return [] }
        
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        
        let output: [DateStructure] = range.compactMap { day in
            return DateStructure(date: calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!,
                                 isNextMonth: isNextMonth, isPrevMonth: isPrevMonth)
        }
        return output
    }
    
    func getAllDatesWithRollOverDates(date: Date) -> [DateStructure] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let firstWeekDay = calendar.component(.weekday, from: startOfMonth)
        let prevMonth = calendar.date(byAdding: .month, value: -1, to: date)
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: date)
        var output = CalendarDayView.getAllDates(date: date, isPrevMonth: false, isNextMonth: false)
        let datesInPrevMonth : [DateStructure] = CalendarDayView.getAllDates(date: prevMonth!, isPrevMonth: true, isNextMonth: false)
        let datesInNextMonth : [DateStructure] = CalendarDayView.getAllDates(date: nextMonth!, isPrevMonth: false, isNextMonth: true)
        let reverseDatesLastMonth = Array(datesInPrevMonth.reversed())
        for i in 0..<firstWeekDay - 1 {
            output.insert(reverseDatesLastMonth[i], at: 0)
        }
        for i in 1...42 - output.count {
            output.append(datesInNextMonth[i - 1])
        }
        return output
    }
    
}

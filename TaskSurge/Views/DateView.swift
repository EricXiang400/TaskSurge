//
//  DateView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 10/10/23.
//

import Foundation
import SwiftUI

struct DateView: View {
    @EnvironmentObject var selectedDate: SelectedDate
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var curUserContainer: AppUser
    @State var offset = CGFloat.zero
    @State var dragOffsetH = CGFloat.zero
    @State var dragOffsetV = CGFloat.zero
    @State var dates: [Date] = []
    
    @Binding public var chosenDate: Date
    
    private let monthArr: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    private let calendar = Calendar.current
    private var daysOfTheWeek: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 7)
        ZStack {
            LazyVGrid(columns: columns) {
                ForEach(userSettings.weekView ? getWeek(date: chosenDate) : getAllDatesWithRollOverDates(date: chosenDate), id: \.self) { day in
                    if CalendarView.isSameDate(date1: chosenDate, date2: day) {
                        Text("\(calendar.component(.day, from: selectedDate.selectedDate))")
                            .frame(width: 30, height: 30)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    } else if CalendarView.isSameDate(date1: Date(), date2: day) {
                        Text("\(calendar.component(.day, from: Date()))")
                            .frame(width: 30, height: 30)
                            .background(Color.blue.opacity(0.5))
                            .clipShape(Circle())
                            .foregroundColor(.white)
                            .onTapGesture {
                                selectedDate.selectedDate = day
                            }
                    } else {
                        Text("\(calendar.component(.day, from: day))")
                            .frame(width: 30, height: 30)
                            .background(Color.clear)
                            .clipShape(Circle())
                            .onTapGesture {
                                selectedDate.selectedDate = day
                            }
                    }
                }
            }
        }
        .gesture(
            DragGesture()
                .onEnded({ value in
                    withAnimation(.interactiveSpring(duration: 0.23)) {
                        let verticalPercent = value.translation.height / (value.translation.width + value.translation.height)
                        let horizontalPercent = value.translation.width / (value.translation.width + value.translation.height)
                        if value.translation.width > 5 && horizontalPercent > 0.8 {
                            if userSettings.weekView {
                                previousWeek()
                            } else {
                                previousMonth()
                            }
                        } else if value.translation.width < -5 && horizontalPercent > 0.8{
                            if userSettings.weekView {
                                nextWeek()
                            } else {
                                nextMonth()
                            }
                        } else if value.translation.height > 5 && verticalPercent > 0.8 {
                            userSettings.weekView = false
                            userSettings.saveLocalSettings()
                            if curUserContainer.curUser != nil {
                                FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                            }
                        } else if value.translation.height < -5 && verticalPercent > 0.8 {
                            userSettings.weekView = true
                            userSettings.saveLocalSettings()
                            if curUserContainer.curUser != nil {
                                FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                            }
                        }
                    }
                })
        )
    }
    func getWeek(date: Date) -> [Date] {
        let datesInLastMonth = getAllDates(date: calendar.date(byAdding: .month, value: -1, to: date)!)
        let datesInNextMonth = getAllDates(date: calendar.date(byAdding: .month, value: 1, to: date)!)
        let datesInMonth = datesInLastMonth + getAllDates(date: date) + datesInNextMonth
        let index = datesInMonth.firstIndex(where: {
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
        let datesInLastMonth : [Date] = getAllDates(date: lastMonth!)
        let reverseDatesLastMonth = Array(datesInLastMonth.reversed())
        for i in 0..<firstWeekDay - 1 {
            output.insert(reverseDatesLastMonth[i], at: 0)
        }
        return output
    }
    
}

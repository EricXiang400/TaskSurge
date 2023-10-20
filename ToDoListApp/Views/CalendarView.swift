//
//  CalenderView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 5/30/23.
//

import Foundation
import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var dateContainer: SelectedDate
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var curUserContainer: AppUser
    @State private var offset = CGFloat.zero
    @State private var dragOffsetH = CGFloat.zero
    @State private var dragOffsetV = CGFloat.zero
    @State var dates: [Date] = []
    @State private var tabViewIndex: Int = 200
    @State var previousWeekDate: Date =
        Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    
    @State var previousMonthDate: Date =
        Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    
    
    @State var nextWeekDate: Date =
        Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    
    
    @State var nextMonthDate: Date =
        Calendar.current.date(byAdding: .month, value: 1, to: Date())!
    
    @State var curDate: Date = Date()
    
    @State var prevTabIndex: Int = 200
    
    @State var tabIndexChanged: Bool = false
    
    private let monthArr: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    private let calendar = Calendar.current
    private var daysOfTheWeek: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    @State var monthArray: [Date] = [Calendar.current.date(byAdding: .month, value: -1, to: Date())!, Date(), Calendar.current.date(byAdding: .month, value: 1, to: Date())!]
    
    @State var weekArray: [Date] = [Calendar.current.date(byAdding: .day, value: -7, to: Date())!, Date(), Calendar.current.date(byAdding: .day, value: 7, to: Date())!]
    
    @State var height: CGFloat = 215
    
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("\(monthArr[calendar.component(.month, from: curDate) - 1])-\(String(calendar.component(.year, from: curDate)))")
                    .bold()
                Spacer()
                if userSettings.showCalendarButton {
                    HStack {
                        Button(action: {
                            if userSettings.weekView {
                                previousWeek()
                            } else {
                                previousMonth()
                            }
                            tabViewIndex -= 1
                        }) {
                            Image(systemName: "arrow.left.circle.fill")
                        }
                        Button {
                            withAnimation(.easeInOut) {
                                toggleView()
                            }
                        } label: {
                            Image(systemName: userSettings.weekView ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                        }
                        Button(action: {
                            if userSettings.weekView {
                                nextWeek()
                            } else {
                                nextMonth()
                            }
                            tabViewIndex += 1
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                        }
                    }
                }
            }
            .padding()
            .font(.title)
            
            HStack(spacing: 15) {
                ForEach(daysOfTheWeek, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .bold()
                }
            }
            TabView(selection: $tabViewIndex) {
                if userSettings.weekView {
                    ForEach(0..<weekArray.count, id: \.self) { index in
                        CalendarDayView(height: $height, date: weekArray[index])
                            .tag(index)
                    }
                } else {
                    ForEach(0..<monthArray.count, id: \.self) { index in
                        CalendarDayView(height: $height, date: monthArray[index])
                            .tag(index)
                    }
                }
            }
            .onChange(of: dateContainer.selectedDate) { newValue in
                if CalendarView.isSameDate(date1: dateContainer.selectedDate, date2: Date()){
                    prevTabIndex = 200
                    tabViewIndex = 200
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: tabViewIndex) { newValue in
                if newValue == weekArray.count - 1 || newValue == monthArray.count {
                    weekArray.append(Calendar.current.date(byAdding: .day, value: 7, to: weekArray.last!)!)
                    monthArray.append(Calendar.current.date(byAdding: .month, value: 1, to: monthArray.last!)!)
                }

                if newValue > prevTabIndex {
                    if userSettings.weekView {
                        curDate = Calendar.current.date(byAdding: .day, value: 7, to: curDate)!
                    } else {
                        curDate = Calendar.current.date(byAdding: .month, value: 1, to: curDate)!
                    }
                } else if newValue < prevTabIndex{
                    if userSettings.weekView {
                        curDate = Calendar.current.date(byAdding: .day, value: -7, to: curDate)!
                    } else {
                        curDate = Calendar.current.date(byAdding: .month, value: -1, to: curDate)!
                    }
                }
                prevTabIndex = newValue

            }
            .frame(height: userSettings.weekView ? 32 : height)
        }
        .onChange(of: dateContainer.selectedDate, perform: { value in
            curDate = dateContainer.selectedDate
        })
        .onAppear {
            dateContainer.selectedDate = Date()
            loadThreeYearsOfWeeksAndMonths()
            userSettings.loadLocalSettings(user: curUserContainer.curUser)
        }
        .padding()
        
    }
    
    func recomputeDates(offset: Int) {
        previousWeekDate = Calendar.current.date(byAdding: .day, value: offset * 7, to: previousWeekDate)!
        previousMonthDate = Calendar.current.date(byAdding: .month, value: offset, to: previousMonthDate)!
        nextWeekDate = Calendar.current.date(byAdding: .day, value: offset * 7, to: nextWeekDate)!
        nextMonthDate = Calendar.current.date(byAdding: .month, value: offset, to: nextMonthDate)!
    }

    func toggleView() {
        userSettings.weekView.toggle()
        userSettings.saveLocalSettings()
        if curUserContainer.curUser != nil {
            FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
        }
    }
    
    static func isSameDate(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.month, from: date1) == calendar.component(.month, from: date2) && calendar.component(.day, from: date1) == calendar.component(.day, from: date2) && calendar.component(.year, from: date1) == calendar.component(.year, from: date2)
    }
    
    func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: dateContainer.selectedDate) {
            dateContainer.selectedDate = newDate
        }
    }
    
    func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: dateContainer.selectedDate) {
            dateContainer.selectedDate = newDate
        }
    }
    
    func nextWeek() {
        if let newDate = calendar.date(byAdding: .day, value: +7, to: dateContainer.selectedDate) {
            dateContainer.selectedDate = newDate
        }
    }
    
    func previousWeek() {
        if let newDate = calendar.date(byAdding: .day, value: -7, to: dateContainer.selectedDate) {
            dateContainer.selectedDate = newDate
        }
    }
    
    func loadThreeYearsOfWeeksAndMonths() {
        let curDate = Date()
        for i in 2...200 {
            weekArray.insert(Calendar.current.date(byAdding: .day, value: -i * 7, to: Date())!, at: 0)
            monthArray.insert(Calendar.current.date(byAdding: .month, value: -i, to: Date())!, at: 0)
        }
    }
}

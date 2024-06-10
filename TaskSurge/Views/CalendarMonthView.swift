//
//  CalendarMonthView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 10/22/23.
//

import Foundation
import SwiftUI

struct CalendarMonthView: View {
    @EnvironmentObject var dateContainer: SelectedDate
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var curUserContainer: AppUser
    @EnvironmentObject var todoListContainer: TodoList
    @EnvironmentObject var categoryContainer: CategoriesData
    @EnvironmentObject var selectedDateContainer: SelectedDate
    @EnvironmentObject var lastModifiedTimeContainer: LastModifiedTime
    @EnvironmentObject var lastModifiedByContainer: LastModifiedBy
    @State private var offset = CGFloat.zero
    @State private var dragOffsetH = CGFloat.zero
    @State private var dragOffsetV = CGFloat.zero
    @State var dates: [Date] = []

    @State var previousMonthDate: Date =
        Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    
    @State var nextMonthDate: Date =
        Calendar.current.date(byAdding: .month, value: 1, to: Date())!
    
    @State var curDate: Date = Date()
    
    @State var prevMonthTabIndex: Int = 50
    
    @State var monthTabIndex: Int = 50
    
    @State var tabIndexChanged: Bool = false
    
    private let monthArr: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    private let calendar = Calendar.current
    
    private var daysOfTheWeek: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    @State var monthArray: [Date]
    
    @State var height: CGFloat = 175
    
    init() {
//        Init the hard coded dates
        var arr = [Calendar.current.date(byAdding: .month, value: -1, to: Date())!, Date(), Calendar.current.date(byAdding: .month, value: 1, to: Date())!]
        for i in 1...50 {
            arr.append(Calendar.current.date(byAdding: .month, value: 1, to: arr.last!)!)
        }
        let curDate = Date()
        for i in 2...50 {
            arr.insert(Calendar.current.date(byAdding: .month, value: -i, to: Date())!, at: 0)
        }
        self.monthArray = arr
    }
    
    var body: some View {
        VStack(spacing: 1) {
            HStack {
                Text("\(monthArr[calendar.component(.month, from: curDate) - 1])-\(String(calendar.component(.year, from: curDate)))")
                    .bold()
                Spacer()
                if userSettings.showCalendarButton {
                    HStack {
                        Button(action: {
                            monthTabIndex -= 1
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
                            monthTabIndex += 1
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                        }
                    }
                }
            }
            .padding(.vertical)
            .font(.title)
            HStack(spacing: 15) {
                ForEach(daysOfTheWeek, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .fontWeight(.heavy)
                }
            }
            TabView(selection: $monthTabIndex) {
                ForEach(0..<monthArray.count, id: \.self) { index in
                    CalendarDayView(height: $height, date: monthArray[index], tabViewIndex: $monthTabIndex)
                        .tag(index)
                }
            }
            .onChange(of: dateContainer.selectedDate) { newValue in
                monthTabIndex = getMonthTabIndex(date: Date())
                prevMonthTabIndex = monthTabIndex
                curDate = dateContainer.selectedDate
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: monthTabIndex) { newValue in
                if newValue > prevMonthTabIndex {
                    curDate = Calendar.current.date(byAdding: .month, value: 1, to: curDate)!
                } else if newValue < prevMonthTabIndex{
                    curDate = Calendar.current.date(byAdding: .month, value: -1, to: curDate)!
                }
                prevMonthTabIndex = newValue

            }
            .frame(height: userSettings.weekView ? 27 : height)
        }
        .onAppear {
            dateContainer.selectedDate = Date()
            userSettings.loadLocalSettings(user: curUserContainer.curUser)
        }
        .padding(.horizontal)
    }
    
    func recomputeDates(offset: Int) {
        previousMonthDate = Calendar.current.date(byAdding: .month, value: offset, to: previousMonthDate)!
        nextMonthDate = Calendar.current.date(byAdding: .month, value: offset, to: nextMonthDate)!
    }

    func toggleView() {
        userSettings.weekView.toggle()
        userSettings.saveLocalSettings()
    }
    
    func addOneMonth(date: Date) {
        monthArray.append(Calendar.current.date(byAdding: .month, value: 1, to: monthArray.last!)!)
    }

    
    func loadThreeYearsOfMonths() {
        for i in 2...200 {
            monthArray.insert(Calendar.current.date(byAdding: .month, value: -i, to: Date())!, at: 0)
        }
    }
    
    func getMonthTabIndex(date: Date) -> Int {
        for i in 0...monthArray.count - 1 {
            if CalendarDayView.getAllDates(date: monthArray[i], isPrevMonth: false, isNextMonth: false).contains(where: {CalendarWeekView.isSameDate(date1: $0.date, date2: dateContainer.selectedDate)}) {
                return i
            }
        }
        return monthArray.count - 1
    }
}

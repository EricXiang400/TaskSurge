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
    @State private var offset = CGFloat.zero
    @State private var dragOffsetH = CGFloat.zero
    @State private var dragOffsetV = CGFloat.zero
    @State var dates: [Date] = []

    @State var previousMonthDate: Date =
        Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    
    @State var nextMonthDate: Date =
        Calendar.current.date(byAdding: .month, value: 1, to: Date())!
    
    @State var curDate: Date = Date()
    
    @State var prevMonthTabIndex: Int = 200
    
    @State var monthTabIndex: Int = 200
    
    @State var tabIndexChanged: Bool = false
    
    private let monthArr: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    private let calendar = Calendar.current
    
    private var daysOfTheWeek: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    @State var monthArray: [Date] = [Calendar.current.date(byAdding: .month, value: -1, to: Date())!, Date(), Calendar.current.date(byAdding: .month, value: 1, to: Date())!]
    
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
                            previousMonth()
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
                            nextMonth()
                            monthTabIndex += 1
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
            TabView(selection: $monthTabIndex) {
                ForEach(0..<monthArray.count, id: \.self) { index in
                    CalendarDayView(height: $height, date: monthArray[index])
                        .tag(index)
                }
            }
            .onChange(of: dateContainer.selectedDate) { newValue in
                if CalendarWeekView.isSameDate(date1: dateContainer.selectedDate, date2: Date()) {
                    prevMonthTabIndex = getMonthTabIndex(date: Date())
                    monthTabIndex = getMonthTabIndex(date: Date())
                }
                curDate = dateContainer.selectedDate
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: monthTabIndex) { newValue in
                if newValue == monthArray.count - 1 || newValue == monthArray.count {
                    addOneMonth(date: monthArray.last!)
                }
                if newValue > prevMonthTabIndex {
                    curDate = Calendar.current.date(byAdding: .month, value: 1, to: curDate)!
                } else if newValue < prevMonthTabIndex{
                    curDate = Calendar.current.date(byAdding: .month, value: -1, to: curDate)!
                }
                prevMonthTabIndex = newValue

            }
            .frame(height: userSettings.weekView ? 32 : height)
        }
        .onAppear {
            dateContainer.selectedDate = Date()
            loadThreeYearsOfMonths()
            userSettings.loadLocalSettings(user: curUserContainer.curUser)
        }
        .padding()
    }
    
    func recomputeDates(offset: Int) {
        previousMonthDate = Calendar.current.date(byAdding: .month, value: offset, to: previousMonthDate)!
        nextMonthDate = Calendar.current.date(byAdding: .month, value: offset, to: nextMonthDate)!
    }

    func toggleView() {
        userSettings.weekView.toggle()
        userSettings.saveLocalSettings()
        if curUserContainer.curUser != nil {
            FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
        }
    }
    
    func addOneMonth(date: Date) {
        monthArray.append(Calendar.current.date(byAdding: .month, value: 1, to: monthArray.last!)!)
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
    
    func loadThreeYearsOfMonths() {
        for i in 2...200 {
            monthArray.insert(Calendar.current.date(byAdding: .month, value: -i, to: Date())!, at: 0)
        }
    }
    
    func getMonthTabIndex(date: Date) -> Int {
        for i in 195...monthArray.count - 1 {
            if CalendarDayView.getAllDates(date: monthArray[i]).contains(where: {CalendarWeekView.isSameDate(date1: $0, date2: Date())}) {
                return i
            }
        }
        /// if the current date is not rendered which would happen if user did not manually click next date.
        addOneMonth(date: monthArray.last!)
        return monthArray.count - 1
    }
}

//
//  CalenderView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 5/30/23.
//

import Foundation
import SwiftUI

struct CalendarWeekView: View {
    @EnvironmentObject var dateContainer: SelectedDate
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var curUserContainer: AppUser
    @State private var offset = CGFloat.zero
    @State private var dragOffsetH = CGFloat.zero
    @State private var dragOffsetV = CGFloat.zero
    @State var dates: [Date] = []
    @State var previousWeekDate: Date =
        Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    
    @State var nextWeekDate: Date =
        Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    
    @State var curDate: Date = Date()
    
    @State var prevWeekTabIndex: Int = 200
    
    @State var weekTabIndex: Int = 200
    
    @State var tabIndexChanged: Bool = false
    
    private let monthArr: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    private let calendar = Calendar.current
    private var daysOfTheWeek: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
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
                            previousWeek()
                            weekTabIndex -= 1
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
                            nextWeek()
                            weekTabIndex += 1
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
            TabView(selection: $weekTabIndex) {
                ForEach(0..<weekArray.count, id: \.self) { index in
                    CalendarDayView(height: $height, date: weekArray[index])
                        .tag(index)
                }
            }
            .onChange(of: dateContainer.selectedDate) { newValue in
                if CalendarWeekView.isSameDate(date1: dateContainer.selectedDate, date2: Date()){
                    prevWeekTabIndex = getWeekTabIndex(date: Date())
                    weekTabIndex = getWeekTabIndex(date: Date())
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: weekTabIndex) { newValue in
                if newValue == weekArray.count - 1 || newValue == weekArray.count {
                    addFourWeeks(date: weekArray.last!)
                }
                if newValue > prevWeekTabIndex {
                    curDate = Calendar.current.date(byAdding: .day, value: 7, to: curDate)!
                } else if newValue < prevWeekTabIndex {
                    curDate = Calendar.current.date(byAdding: .day, value: -7, to: curDate)!
                }
                prevWeekTabIndex = newValue

            }
            .frame(height: userSettings.weekView ? 32 : height)
        }
        .onChange(of: dateContainer.selectedDate, perform: { value in
            curDate = dateContainer.selectedDate
        })
        .onAppear {
            dateContainer.selectedDate = Date()
            loadThreeYearsOfWeeks()
            userSettings.loadLocalSettings(user: curUserContainer.curUser)
        }
        .padding()
    }
    
    func recomputeDates(offset: Int) {
        previousWeekDate = Calendar.current.date(byAdding: .day, value: offset * 7, to: previousWeekDate)!
        nextWeekDate = Calendar.current.date(byAdding: .day, value: offset * 7, to: nextWeekDate)!
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
    
    func addFourWeeks(date: Date) {
        for i in 1...4 {
            weekArray.append(Calendar.current.date(byAdding: .day, value: i * 7, to: weekArray.last!)!)
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
    
    func loadThreeYearsOfWeeks() {
        let curDate = Date()
        for i in 2...200 {
            weekArray.insert(Calendar.current.date(byAdding: .day, value: -i * 7, to: Date())!, at: 0)
        }
    }
    
    func getWeekTabIndex(date: Date) -> Int {
        for i in 195...weekArray.count - 1 {
            if CalendarDayView.getWeek(date: weekArray[i]).contains(where: {CalendarWeekView.isSameDate(date1: $0, date2: Date())}) {
                return i
            }
        }
        /// if the current date is not rendered which would happen if user did not manually click next date.
        addFourWeeks(date: weekArray.last!)
        return weekArray.count - 1
    }
    
}
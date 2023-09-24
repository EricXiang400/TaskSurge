//
//  TodoListView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 5/30/23.
//

import Foundation
import SwiftUI
import Firebase

struct TodoListView: View {
    @EnvironmentObject private var todoListContainer: TodoList
    @EnvironmentObject private var selectedDateContainer: SelectedDate
    @EnvironmentObject var selectedDate: SelectedDate
    @EnvironmentObject private var curUserContainer: AppUser
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var categoryContainer: CategoriesData
    @Environment(\.scenePhase) var scenePhase
    @State var showConfirmationSheet: Bool = false
    @State var objectIndex: Int? = nil
    @Binding var showCalendar: Bool
    @Binding var showSideMenu: Bool
    @State var taskDescription: String = ""
    @State private var selectedFont: UIFont = UIFont.systemFont(ofSize: 14)
    @State var showSortingOptions: Bool = false
    @Binding var selectedTodoContent: TodoContent
    @Binding var showProgressEditView: Bool
    @State var showTaskDetails: Bool = false
    @State var tempTodoContent: TodoContent = TodoContent(content: "", completed: false, date: Date())
    @State var tempTodoContentCopy: TodoContent = TodoContent(content: "", completed: false, date: Date())
    @State var presentSheet: Bool = false
    @State var isNewTask: Bool = true
    @Binding var sideMenuOffset: CGFloat
    @Environment(\.colorScheme) var colorScheme
    var backgroundColor: Color {
        if userSettings.darkMode {
            Color(red: 0.1, green: 0.1, blue: 0.1)
        } else {
            Color.white
        }
    }
    
    var offSetHeight: Int = 44
    
    var offSetCount: Int {
        var count:Int = 0
        for todo in todoListContainer.todoList {
            if sameDate(date1: selectedDateContainer.selectedDate, date2: todo.date) && todoListContainer.selectedCategory == todo.category {
                count += 1
            }
        }
        return count
    }
    
    func sameDate(date1: Date, date2: Date) -> Bool {
        return Calendar.current.compare(date1, to: date2, toGranularity: .day) == .orderedSame
    }
    
    func clearDocumentDirectory() -> Bool {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: [])
            
            for fileURL in fileURLs {
                try fileManager.removeItem(at: fileURL)
            }
            print("All files removed successfully.")
        } catch {
            print("Error while clearing document directory: \(error.localizedDescription)")
        }
        return true
    }
    
    func saveData() {
        todoListContainer.saveLocalData()
        if curUserContainer.curUser != nil {
            FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
        }
    }
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea(.all)
            VStack {
                HStack {
                    Button(action: {
                        UIApplication.shared.endEditing()
                        withAnimation(.easeInOut(duration: 0.23)) {
                            sideMenuOffset = -55
                            showSideMenu = true
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .imageScale(.large)
                    }
                    .padding(.leading)
                    Spacer()
                    Button {
                        UIApplication.shared.endEditing()
                        selectedDateContainer.selectedDate = Date()
                    } label: {
                        Text("Today")
                            .font(.system(size: 13))
                            .bold()
                    }
                    .padding(.vertical,4.5)
                    .padding(.horizontal, 4)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                    
                    Button (action: {
                        UIApplication.shared.endEditing()
                        showSortingOptions.toggle()
                    }) {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                            .font(.system(size: 25))
                    }
                    Button(action:{
                        UIApplication.shared.endEditing()
                        if todoListContainer.selectedCategory != nil {
                            withAnimation(.easeInOut) {
                                tempTodoContent = TodoContent(content: "", completed: false, date: selectedDateContainer.selectedDate, category: todoListContainer.selectedCategory!)
                                
                                tempTodoContentCopy = tempTodoContent
                                presentSheet = true
                            }
                        }
                    }) {
                        if todoListContainer.selectedCategory == nil {
                            Circle()
                                .foregroundColor(.blue)
                                .frame(width: 25, height: 25)
                                .overlay(
                                    Image(systemName: "plus")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .opacity(0.5)
                                )
                        } else {
                            Circle()
                                .foregroundColor(.blue)
                                .frame(width: 25, height: 25)
                                .overlay(
                                    Image(systemName: "plus")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    .padding(.trailing, 10)
                    .sheet(isPresented: $presentSheet) {
                        EditTaskView(todoContentCopy: $tempTodoContentCopy, todoContentOriginal: $tempTodoContent, showTaskDetails: $presentSheet, isNewTask: $isNewTask) {
                            tempTodoContent = tempTodoContentCopy
                            todoListContainer.todoList.append(tempTodoContent)
                            sortTask()
                            saveData()
                        }
                    }
                }
                
                ZStack {
                    List(todoListContainer.todoList) { todo in
                        if sameDate(date1: selectedDateContainer.selectedDate, date2: todo.date) && todoListContainer.selectedCategory == todo.category {
                            var todoIndex: Int {
                                todoListContainer.todoList.firstIndex(where: {$0.id == todo.id})!
                            }
                            HStack {
                                if !userSettings.circularProgressBar {
                                    Button(action: {
                                        if todoListContainer.todoList[todoIndex].content != "" {
                                            if todoListContainer.todoList[todoIndex].progress != 100.0 && !todoListContainer.todoList[todoIndex].completed {
                                                objectIndex = todoIndex
                                                showConfirmationSheet = true
                                            } else {
                                                todoListContainer.todoList[todoIndex].completed.toggle()
                                            }
                                        } else if todoListContainer.todoList[todoIndex].completed {
                                            todoListContainer.todoList[todoIndex].completed.toggle()
                                        }
                                        saveData()
                                    }) {
                                        Image(systemName: todoListContainer.todoList[todoIndex].completed ?  "checkmark.circle.fill" : "circle")
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                            .foregroundColor(todoListContainer.todoList[todoIndex].completed ? Color(red: 0, green: 0.7, blue: 0) : .primary)
                                    }
                                    .padding(5)
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                if userSettings.showProgressBar && userSettings.circularProgressBar {
                                    ZStack {
                                        Text("\(Int(todoListContainer.todoList[todoIndex].progress))")
                                            .font(.system(size: 10))
                                            .bold()
                                        CircularProgressView(todoContent: $todoListContainer.todoList[todoIndex])
                                            .frame(width: 25, height: 25)
                                            .padding(5)
                                    }
                                }
                                
                                TaskView(todoContent: $todoListContainer.todoList[todoIndex], todoContentCopyPassIn: todoListContainer.todoList[todoIndex])
                                if userSettings.showProgressBar {
                                    if !userSettings.circularProgressBar {
                                        ProgressBarView(todoContent: $todoListContainer.todoList[todoIndex], selectedTodoContent: $selectedTodoContent,
                                                            showProgressEditView: $showProgressEditView)
                                    }
                                }
                                
                            }
                            .listRowBackground(backgroundColor)
                            .contentShape(Rectangle())
                            .cornerRadius(5)
                            
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(action: {
                                    todoListContainer.todoList.remove(at: todoIndex)
                                    saveData()
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                        }
                    }
                    
                    .listStyle(.plain)
                    .onAppear {
                        todoListContainer.loadLocalData(user: curUserContainer.curUser)
                        userSettings.loadLocalSettings(user: curUserContainer.curUser)
                        categoryContainer.loadLocalCategories()
                        let curCategory = Category.loadLocalCategory(user: curUserContainer.curUser)
                        if curCategory != nil && categoryContainer.categories.contains(curCategory!) {
                            todoListContainer.selectedCategory = curCategory
                        }
                        moveLayoverItems()
                        saveData()
                    }
                    .onChange(of: scenePhase) { newValue in
                        if newValue == .active && curUserContainer.curUser != nil {
                            FireStoreManager.firestoreToLocal(uid: Auth.auth().currentUser!.uid) {
                                todoListContainer.loadLocalData(user: curUserContainer.curUser)
                                userSettings.loadLocalSettings(user: curUserContainer.curUser)
                                categoryContainer.loadLocalCategories()
                                let curCategory = Category.loadLocalCategory(user: curUserContainer.curUser)
                                if curCategory != nil && categoryContainer.categories.contains(curCategory!) {
                                    todoListContainer.selectedCategory = curCategory
                                }
                                moveLayoverItems()
                                saveData()
                            }
                        }
                    }
                    Color.white.opacity(0.00000001)
                        .offset(y: CGFloat(offSetCount * offSetHeight))
                        .onTapGesture {
                            tempTodoContent = TodoContent(content: "", completed: false, date: selectedDateContainer.selectedDate, category: todoListContainer.selectedCategory!)
                            
                            tempTodoContentCopy = tempTodoContent
                            presentSheet = true
                        }
                        .sheet(isPresented: $presentSheet) {
                            EditTaskView(todoContentCopy: $tempTodoContentCopy, todoContentOriginal: $tempTodoContent, showTaskDetails: $presentSheet, isNewTask: $isNewTask) {
                                tempTodoContent = tempTodoContentCopy
                                todoListContainer.todoList.append(tempTodoContent)
                                sortTask()
                                saveData()
                            }
                        }
                }
            }
//            .background(backgroundColor)
            
            if showSortingOptions {
                Color.white.opacity(0.0001)
                    .onTapGesture {
                        showSortingOptions = false
                    }
                    .ignoresSafeArea(.all)
                VStack {
                    Spacer()
                    SortOptionsView(showSortingOptions: $showSortingOptions)
                        .frame(width: UIScreen.main.bounds.width - 250, height: 150)
                        .offset(x: 100, y: userSettings.weekView ? -UIScreen.main.bounds.height / 1.85 : -UIScreen.main.bounds.height / 2.65)
                }
            }
        }
        .background(backgroundColor)
    }
    
    func sortTask() {
        if userSettings.sortOption == 1 {
            todoListContainer.todoList.sort(by: {
                if $0.progress == $1.progress {
                    return $1.date < $0.date
                }
                return $0.progress < $1.progress
            })
        }
    }
    
    func taskLayoverExist(todoContent: TodoContent) -> Bool {
        if !userSettings.taskLayover {
            return false
        }
        let calendar = Calendar.current
        let yesterDateAndTime = calendar.date(byAdding: .day, value: -1, to: Date())!
        return CalendarView.isSameDate(date1: yesterDateAndTime, date2: todoContent.date) && !todoContent.completed
    }
    func moveLayoverItems() {
        for i in todoListContainer.todoList.indices {
            if taskLayoverExist(todoContent: todoListContainer.todoList[i]) {
                todoListContainer.todoList[i].date = Date()
            }
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

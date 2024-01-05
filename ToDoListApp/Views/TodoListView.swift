//
//  TodoListView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 5/30/23.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import Network

struct TodoListView: View {
    @EnvironmentObject var dateContainer: SelectedDate
    @EnvironmentObject private var todoListContainer: TodoList
    @EnvironmentObject private var selectedDateContainer: SelectedDate
    @EnvironmentObject var selectedDate: SelectedDate
    @EnvironmentObject private var curUserContainer: AppUser
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var categoryContainer: CategoriesData
    @EnvironmentObject private var lastModifiedTimeContainer: LastModifiedTime
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
    @State var tempTodoContent: TodoContent = TodoContent(content: "", completed: false, date: Date(), taskSortID: 0, subTaskList: [])
    @State var tempTodoContentCopy: TodoContent = TodoContent(content: "", completed: false, date: Date(), taskSortID: 0, subTaskList: [])
    @State var presentSheet: Bool = false
    @State var isNewTask: Bool = true
    @Binding var sideMenuOffset: CGFloat
    @Environment(\.colorScheme) var colorScheme
    @State var noCircularConfirmation: Bool = false
    @State private var listenerRegistration: ListenerRegistration? = nil
    @State var fetchingData: Bool = false
    @State var isConnected: Bool = false
    @State var prevConnectionState: Bool = false
    @State var dataSentByThisDevice: Bool = false
    var minLoadingTime: TimeInterval = 2
    var backgroundColor: Color {
        if userSettings.darkMode {
            Color(red: 0.1, green: 0.1, blue: 0.1)
        } else {
            Color(red: 0.95, green: 0.95, blue: 0.95)
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
            updateLastModifiedTime()
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
                        selectedDateContainer.selectedDate = Date()
                    } label: {
                        Text("Today")
                            .font(.system(size: 14))
                            .fontWeight(.heavy)
                    }
                    .padding(.vertical,4.5)
                    .padding(.horizontal, 4)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                    
                    Button (action: {
                        userSettings.sortOption.toggle()
                        userSettings.saveLocalSettings()
                        sortTask()
                        saveData()
                    }) {
                        if userSettings.sortOption {
                            Image(systemName: "line.horizontal.3.decrease.circle")
                                .rotationEffect(.degrees(180))
                                .font(.system(size: 25))
                        } else {
                            Image(systemName: "line.horizontal.3.circle")
                                .font(.system(size: 25))
                        }
                    }
                    
                    Button(action:{
                        UIApplication.shared.endEditing()
                        withAnimation(.easeInOut) {
                            if todoListContainer.selectedCategory == nil {
                                todoListContainer.selectedCategory = Category(name: "Untitled")
                                categoryContainer.categories.append(todoListContainer.selectedCategory!)
                                categoryContainer.saveLocalCategories()
                                if curUserContainer.curUser != nil {
                                    FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                                }
                            }
                            tempTodoContent = TodoContent(content: "", completed: false, date: selectedDateContainer.selectedDate, category: todoListContainer.selectedCategory!, taskSortID: todoListContainer.taskSortID, subTaskList: [])
                            tempTodoContentCopy = tempTodoContent
                            presentSheet = true
                        }
                    }) {
                        Circle()
                            .foregroundColor(.blue)
                            .frame(width: 25, height: 25)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                        )
                    }
                    .padding(.trailing, 10)
                    .sheet(isPresented: $presentSheet) {
                        EditTaskView(todoContentCopy: $tempTodoContentCopy, todoContentOriginal: $tempTodoContent, showTaskDetails: $presentSheet, isNewTask: $isNewTask) {
                            tempTodoContent = tempTodoContentCopy
                            todoListContainer.todoList.append(tempTodoContent)
                            todoListContainer.taskSortID += 1
                            sortTask()
                            saveData()
                        }
                    }
                }
                if (fetchingData && isConnected) {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1, anchor: .center)
                            Spacer()
                        }
                }
                ZStack {
                    if (noTodoForCategoryToday()) {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text("+ Tap here to add todos")
                                    .opacity(0.6)
                                    .bold()
                                Spacer()
                            }
                            Spacer()
                            Spacer()
                        }
                    }
                    else {
                        List(todoListContainer.todoList) { todo in
                            if sameDate(date1: selectedDateContainer.selectedDate, date2: userSettings.taskLayover ? todo.date : todo.createdDate) && todoListContainer.selectedCategory == todo.category {
                                var todoIndex: Int {
                                    todoListContainer.todoList.firstIndex(where: {$0.id == todo.id})!
                                }
                                HStack {
                                    if !userSettings.circularProgressBar {
                                        Button(action: {
                                            if todoListContainer.todoList[todoIndex].progress != 100.0 && !todoListContainer.todoList[todoIndex].completed {
                                                todoListContainer.todoList[todoIndex].progress = 100.0
                                                todoListContainer.todoList[todoIndex].completed = true
                                                completeSubtasks(index: todoIndex)
                                                sortTask()
                                                saveData()
                                            } else {
                                                if todoListContainer.todoList[todoIndex].completed {
                                                    todoListContainer.todoList[todoIndex].completed = false
                                                    if !userSettings.showProgressBar {
                                                        todoListContainer.todoList[todoIndex].progress = 0
                                                    }
                                                } else {
                                                    todoListContainer.todoList[todoIndex].completed = true
                                                }
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
                                    } else if userSettings.showProgressBar && userSettings.circularProgressBar {
                                        ZStack {
                                            Text("\(Int(todoListContainer.todoList[todoIndex].progress))")
                                                .font(.system(size: 10))
                                                .bold()
                                            CircularProgressView(todoContent: $todoListContainer.todoList[todoIndex])
                                                .frame(width: 25, height: 25)
                                                .padding(5)
                                                .onTapGesture {
                                                    todoListContainer.todoList[todoIndex].progress = 100.0
                                                    todoListContainer.todoList[todoIndex].completed = true
                                                    sortTask()
                                                    saveData()
                                                }
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
                    }
                    Color.white.opacity(0.00000001)
                        .offset(y: CGFloat(offSetCount * offSetHeight))
                        .onTapGesture {
                            if todoListContainer.selectedCategory == nil {
                                todoListContainer.selectedCategory = Category(name: "Untitled")
                                categoryContainer.categories.append(todoListContainer.selectedCategory!)
                                categoryContainer.saveLocalCategories()
                                if curUserContainer.curUser != nil {
                                    FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                                }
                            }
                            tempTodoContent = TodoContent(content: "", completed: false, date: selectedDateContainer.selectedDate, category: todoListContainer.selectedCategory!, taskSortID: todoListContainer.taskSortID, subTaskList: [])
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
        }
        .onAppear() {
            checkInternetConnection()
        }
        .onChange(of: scenePhase) { newValue in
            if curUserContainer.curUser != nil && (newValue == .inactive || newValue == .active) {
                if listenerRegistration == nil {
                    fetchDataWithAnimation()
                    let db = Firestore.firestore()
                    let taskCollection = db.collection("uid").document("\(curUserContainer.curUser!.uid)")
                    listenerRegistration = taskCollection.addSnapshotListener { snapshot, error in
                        guard let snapshot = snapshot else {
                            print("snapshot is null")
                            return
                        }
                        if !FireStoreManager.dataJustSent {
                            withAnimation(.easeOut(duration: 0.25)) {
                                fetchingData = true
                            }
                        }
                        loadDataFromSnapshot(snapshot: snapshot)
                    }
                }
                
            }
        }
        .background(backgroundColor)
    }
    
    func fetchDataWithAnimation() {
        withAnimation(.easeOut(duration: 0.25)) {
            fetchingData = true
        }
        fetchAndLoadFireStoreData() {
            moveLayoverItems()
            curUserContainer.loadLocalUser()
            updateToCurrentDate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeOut(duration: 0.25)) {
                    fetchingData = false
                }
            }
        }
    }
    
    func loadDataFromSnapshot(snapshot: DocumentSnapshot) {
        if let encodedData = snapshot.data() {
            let uid = curUserContainer.curUser!.uid
            do {
                let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let dataFileURL = documentDirectory.appendingPathComponent("\(uid)-data.json")
                let userFileURL = documentDirectory.appendingPathComponent("\(uid)-user.json")
                let settingsFileURL = documentDirectory.appendingPathComponent("\(uid)-settings.json")
                let categoriesFileURL = documentDirectory.appendingPathComponent("\(uid)-categories.json")
                let categoryFileURL = documentDirectory.appendingPathComponent("\(uid)-category.json")
                let lastModifiedTimeFileURL = documentDirectory.appendingPathComponent("\(uid)-lastModifiedTime.json")
                if let lastModifiedTimeJsonDictData = encodedData["lastModifiedTime"] {
                    let lastModifiedTimeData = try JSONSerialization.data(withJSONObject: lastModifiedTimeJsonDictData)
                    let localLastModifiedTimeEncoded = try Data(contentsOf: lastModifiedTimeFileURL)
                    let decoder = JSONDecoder()
                    let localLastModifiedTimeData = try decoder.decode(LastModifiedTime.self, from: localLastModifiedTimeEncoded)
                    let cloudLastModifiedTimeData = try decoder.decode(LastModifiedTime.self, from: lastModifiedTimeData)
                    if localLastModifiedTimeData.lastModifiedTime < cloudLastModifiedTimeData.lastModifiedTime {
                        if let userJsonDictData = encodedData["user"] {
                            let userJsonData = try JSONSerialization.data(withJSONObject: userJsonDictData)
                            try userJsonData.write(to: userFileURL)
                            print("User data download success snapshot")
                        } else {
                            print("User field is empty")
                        }
                        if let dataJsonDictData = encodedData["data"] {
                            let dataJsonData = try JSONSerialization.data(withJSONObject: dataJsonDictData)
                            try dataJsonData.write(to: dataFileURL)
                            print("Content data download success snapshot")
                        } else {
                            "Content data field is empty"
                        }
                        
                        if let settingsJsonDictData = encodedData["settings"] {
                            let settingsJsonData = try JSONSerialization.data(withJSONObject: settingsJsonDictData)
                            try settingsJsonData.write(to: settingsFileURL)
                            print("Settings data download success snapshot")
                        } else {
                            print("setting field is empty")
                        }
                        if let categoriesJsonDictData = encodedData["categories"] {
                            let categoriesJsonData = try JSONSerialization.data(withJSONObject: categoriesJsonDictData)
                            try categoriesJsonData.write(to: categoriesFileURL)
                            print("categories data download success snapshot")
                        } else {
                            print("categoreis field is empty")
                        }
                        if let categoryJsonDictData = encodedData["category"] {
                            let categoryJsonData = try JSONSerialization.data(withJSONObject: categoryJsonDictData)
                            try categoryJsonData.write(to: categoryFileURL)
                            print("category data download success snapshot")
                        } else {
                            print("category data field is empty")
                        }
                        todoListContainer.loadLocalData(user: curUserContainer.curUser)
                        userSettings.loadLocalSettings(user: curUserContainer.curUser)
                        categoryContainer.loadLocalCategories()
                        let curCategory = Category.loadLocalCategory(user: curUserContainer.curUser)
                        if curCategory != nil && categoryContainer.categories.contains(curCategory!) {
                            todoListContainer.selectedCategory = curCategory
                        }
                        curUserContainer.saveLocalUser(user: curUserContainer.curUser!, userName: curUserContainer.userName)
                        todoListContainer.saveLocalData()
                        userSettings.saveLocalSettings()
                        categoryContainer.saveLocalCategories()
                        lastModifiedTimeContainer.lastModifiedTime = cloudLastModifiedTimeData.lastModifiedTime
                        lastModifiedTimeContainer.saveData()
                    }
                } else {
                    dataSentByThisDevice = true
                }
            } catch {
                print("Error when working with encoded data from cloud")
            }
            if !FireStoreManager.dataJustSent {
                dataSentByThisDevice = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        fetchingData = false
                    }
                }
            }
            
        }
    }
    
    func checkInternetConnection() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                if !prevConnectionState {
                    fetchDataWithAnimation()
                }
                prevConnectionState = isConnected
                isConnected = true
                print("Internet Detected")
            } else {
                prevConnectionState = isConnected
                isConnected = false
                print("Internet Down")
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    func noTodoForCategoryToday()-> Bool {
        return todoListContainer.todoList.filter { todoContent in
            sameDate(date1: todoContent.date, date2: dateContainer.selectedDate) && todoContent.category == todoListContainer.selectedCategory
        }.count == 0
    }
    
    func fetchAndLoadFireStoreData(completion: @escaping () -> Void) {
        FireStoreManager.firestoreToLocal(uid: Auth.auth().currentUser!.uid) {
            todoListContainer.loadLocalData(user: curUserContainer.curUser)
            userSettings.loadLocalSettings(user: curUserContainer.curUser)
            categoryContainer.loadLocalCategories()
            let curCategory = Category.loadLocalCategory(user: curUserContainer.curUser)
            if curCategory != nil && categoryContainer.categories.contains(curCategory!) {
                todoListContainer.selectedCategory = curCategory
            }
            completion()
        }
    }
    
    func sortTask() {
        var previousList = todoListContainer.todoList
        if userSettings.sortOption {
            todoListContainer.todoList.sort(by: {
                return $0.progress < $1.progress
            })
        } else {
            todoListContainer.todoList.sort(by: {
                return $0.taskSortID < $1.taskSortID
            })
        }
    }
    
    func taskLayoverExist(todoContent: TodoContent) -> Bool {
        if !userSettings.taskLayover {
            return false
        }
        return sameDate(date1: curUserContainer.lastActiveDate, date2: todoContent.date) && !sameDate(date1: Date(), date2: curUserContainer.lastActiveDate) && !todoContent.completed
    }
    
    func updateToCurrentDate() {
        if !sameDate(date1: curUserContainer.lastActiveDate, date2: Date()) {
            // This function saves the lastActiveDate
            curUserContainer.saveLocalUser(user: curUserContainer.curUser!, userName: curUserContainer.userName)
            FireStoreManager.localToFirestore(uid: curUserContainer.uid)
        }
    }
    
    func moveLayoverItems() {
        var saveRequired: Bool = false
        for i in todoListContainer.todoList.indices {
            if taskLayoverExist(todoContent: todoListContainer.todoList[i]) {
                todoListContainer.todoList[i].date = Date()
                saveRequired = true
            }
        }
        if saveRequired {
            saveData()
        }
    }
    
    func updateLastModifiedTime() {
        lastModifiedTimeContainer.lastModifiedTime = Date()
        lastModifiedTimeContainer.saveData()
    }
    
    func decodeData(from document: QueryDocumentSnapshot) -> Data {
        do {
            let encodedData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
            return encodedData
        } catch {
            print("Error when dealing with category snapshot")
            return Data()
        }
    }
    
    func completeSubtasks(index: Int) {
        for i in todoListContainer.todoList[index].subTaskList.indices {
            todoListContainer.todoList[index].subTaskList[i].completed = true
        }
    }
    
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

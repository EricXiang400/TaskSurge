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
    @EnvironmentObject private var curUserContainer: AppUser
    @State var showConfirmationSheet: Bool = false
    @State var objectIndex: Int? = nil
    @Binding var showCalendar: Bool
    @Binding var showSideMenu: Bool
    @State private var isEditing: Bool = false
    @State var taskDescription: String = ""
    @State private var selectedFont: UIFont = UIFont.systemFont(ofSize: 14)
    @State var showSortingOptions: Bool = false
    @State var selectedSortOption: Int = 1
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
                print("Removed file: \(fileURL.lastPathComponent)")
            }
            print("All files removed successfully.")
        } catch {
            print("Error while clearing document directory: \(error.localizedDescription)")
        }
        return true
    }
    
    func saveDataOnCommit() {
        todoListContainer.saveLocalData()
        if curUserContainer.curUser != nil {
            FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
        }
        isEditing = false
    }
    var dateFilteredTodos: [TodoContent] {
        return todoListContainer.todoList.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDateContainer.selectedDate) }
    }
    
//    var progressFilteredTodos: [TodoContent] {
//
//    }
    
    var body: some View {
        ZStack {
            VStack {
                CalenderView()
                HStack {
                    Button(action: {
                        showSideMenu = true
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .imageScale(.large)
                    }
                    .padding(.leading)
                    Spacer()
                    Button (action: {
                        showSortingOptions.toggle()
                    }) {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                            .font(.system(size: 25))
                    }
                    Button(action:{
                        todoListContainer.todoList.append(TodoContent(content: "", completed: false, date: selectedDateContainer.selectedDate))
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
                    .padding(10)
                }
                
                List(dateFilteredTodos) { todo in
                    if sameDate(date1: selectedDateContainer.selectedDate, date2: todo.date) {
                        var todoIndex: Int {
                            todoListContainer.todoList.firstIndex(where: {$0.id == todo.id})!
                        }
                        HStack {
                            Button {
                                if todoListContainer.todoList[todoIndex].content != "" {
                                    if todoListContainer.todoList[todoIndex].progress != 100.0 && !todoListContainer.todoList[todoIndex].completed {
                                        objectIndex = todoIndex
                                    } else {
                                        todoListContainer.todoList[todoIndex].completed.toggle()
                                    }
                                } else if todoListContainer.todoList[todoIndex].completed {
                                    todoListContainer.todoList[todoIndex].completed.toggle()
                                }
                                todoListContainer.saveLocalData()
                                if curUserContainer.curUser != nil {
                                    FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                                }
                            } label: {
                                Label("Toggle Selected", systemImage: todoListContainer.todoList[todoIndex].completed ?  "checkmark.circle.fill" : "circle")
                                    .labelStyle(.iconOnly)
                                    .foregroundColor(todoListContainer.todoList[todoIndex].completed ? Color(red: 0, green: 0.7, blue: 0) : .primary)
                            }
                            .contentShape(Circle())
                            .padding(5)
                            if todoListContainer.todoList[todoIndex].completed {
                                TextField("Task Name", text: $todoListContainer.todoList[todoIndex].content, onCommit: saveDataOnCommit)
                                    .strikethrough(true)
                            } else {
                                TextField("Task Name", text: $todoListContainer.todoList[todoIndex].content, onCommit: saveDataOnCommit)
                            }
                            if todoListContainer.todoList[todoIndex].content != "" {
                                ProgressBarView(todoContent: $todoListContainer.todoList[todoIndex])
                            }
                        }
                        .alert(isPresented: $showConfirmationSheet) {
                            Alert(
                                title: Text("Task Completion"),
                                message: Text("Are you sure you want to complete this task?"),
                                primaryButton: .default(Text("Complete")) {
                                    // Handle OK button action
                                    todoListContainer.todoList[objectIndex!].progress = 100.0
                                    todoListContainer.todoList[objectIndex!].completed = true
                                    todoListContainer.saveLocalData()
                                    if curUserContainer.curUser != nil {
                                        FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                                    }
                                },
                                secondaryButton: .cancel()
                            )
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(action: {
                                todoListContainer.todoList.remove(at: todoIndex)
                                todoListContainer.saveLocalData()
                                if curUserContainer.curUser != nil {
                                    FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                                }
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                    }
                }
                .listStyle(.plain)
                .onAppear {
                    todoListContainer.todoList = TodoList.loadLocalData(user: curUserContainer.curUser)
                }
            }
        if showSortingOptions {
            Color.white.opacity(0.1)
                .onTapGesture {
                    showSortingOptions = false
                }
                .ignoresSafeArea(.all)
            VStack {
                Spacer()
                SortOptionsView(selectedSortOption: $selectedSortOption, showSortingOptions: $showSortingOptions)
                    .frame(width: UIScreen.main.bounds.width - 40, height: 150)
                    .offset(x: 100, y: -UIScreen.main.bounds.width / 1.5)
                    .animation(.spring())
            }
        }
    }
    }
}

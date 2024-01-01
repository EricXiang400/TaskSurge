//
//  MenuContent.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 7/11/23.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct MenuContentView: View {
    @EnvironmentObject var curUserContainer: AppUser
    @EnvironmentObject private var todoListContainer: TodoList
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var categoryContainer: CategoriesData
    @Binding var isShowingSetting: Bool
    @Environment(\.colorScheme) var colorScheme
    @Binding var showSideMenu: Bool
    @Binding var menuOffset: CGFloat
    @Binding var settingViewOffset: CGFloat
    @State var categoryIndex: Int = 0
    var categoryRowOffset: Int = 48
    let fromTopTransition = AnyTransition.opacity.combined(with: .offset(y: -25))

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button (action: {
                    withAnimation(.easeInOut) {
                        showSideMenu = false
                        menuOffset = -UIScreen.main.bounds.width * (3/4) - 55
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                }
                .padding(.leading, 6.5)
                .padding(.top)
                Spacer()
            }
            .padding(.leading)
            
            HStack {
                Text("Categories")
                    .font(.title)
                    .bold()
                Spacer()
                Button (action: {
                    UIApplication.shared.endEditing()
                    categoryContainer.categories.append(Category(name: "Untitled"))
                    categoryContainer.saveLocalCategories()
                    if curUserContainer.curUser != nil {
                        FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                    }
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 17, height: 17)
                        .cornerRadius(10)
                }
            }
            .padding()
            ZStack {
                ScrollView {
                    ForEach(Array(categoryContainer.categories.enumerated()), id: \.offset) { index, strElem in
                        HStack {
                            Spacer()
                            CategoryRow(category: $categoryContainer.categories[index], delete: {
                                removeRelatedTodos(category: todoListContainer.selectedCategory!)
                                todoListContainer.selectedCategory = nil
                                categoryContainer.categories.remove(at: index)
                                categoryContainer.saveLocalCategories()
                                if curUserContainer.curUser != nil {
                                    FireStoreManager.localToFirestore(uid: curUserContainer.curUser!.uid)
                                }
                            })
                            
                            Spacer()
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15))
                        .transition(fromTopTransition)
                        .animation(.easeInOut)
                    }
                }
            }
            Spacer()
            ZStack {
                if colorScheme == .light {
                    Color(red: 0.95, green: 0.95, blue: 0.95)
                        .ignoresSafeArea(.all)
                        .frame(height: 45)
                        .shadow(radius: 3)
                } else {
                    Color(red: 0.15, green: 0.15, blue: 0.15)
                        .ignoresSafeArea(.all)
                        .frame(height: 45)
                        .shadow(radius: 3)
                }
                
                HStack {
                    // Settings button
                    Button (action: {
                        UIApplication.shared.endEditing()
                        withAnimation(.easeInOut(duration: 0.22)) {
                            isShowingSetting = true
                            settingViewOffset = 0
                        }
                    }) {
                        Image(systemName: "gearshape") // SF Symbol for settings
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .padding(.trailing)
                    .padding(.leading)
                    Spacer()
                }
                
            }
        }
        .onAppear {
            categoryContainer.loadLocalCategories()
            var curCategory = Category.loadLocalCategory(user: curUserContainer.curUser)
            if curCategory != nil && categoryContainer.categories.contains(curCategory!) {
                todoListContainer.selectedCategory = curCategory
            }
        }
    }
    
    func removeRelatedTodos(category: Category) {
        var toRemove: [TodoContent] = []
        for i in todoListContainer.todoList.indices {
            if todoListContainer.todoList[i].category.id == category.id {
                toRemove.append(todoListContainer.todoList[i])
            }
        }
        for todoContent in toRemove {
            todoListContainer.todoList.removeAll(where: { $0.id == todoContent.id })
        }
        todoListContainer.saveLocalData()
    }
}

struct MenuItem: Identifiable, Hashable {
    static var lastAssignedID: Int = 0
    var itemName: String
    var id: Int
    
    init(itemName: String) {
        self.itemName = itemName
        MenuItem.lastAssignedID += 1
        self.id = MenuItem.lastAssignedID
    }
    
    
}


extension Color {
    static func primaryColor(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .light ? Color.white : Color.black
    }
}


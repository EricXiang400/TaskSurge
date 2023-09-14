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
    @Binding var showLoginView: Bool
    @Environment(\.colorScheme) var colorScheme
    @Binding var showSideMenu: Bool
    @Binding var menuOffset: CGFloat
    @State var categoryIndex: Int = 0
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
                Spacer()
            }
            .padding()
            HStack {
                Image(systemName: "person.circle")
                    .font(.system(size: 28))
                    .padding(.leading, 18)
                if curUserContainer.curUser != nil {
                    Text("Hi, \(TodoList.loadLocalUser()?.userName ?? "Unknown")")
                        .bold()
                    Button {
                        if signOut() {
                            curUserContainer.curUser = nil
                            todoListContainer.loadLocalData(user: nil)
                            userSettings.loadLocalSettings(user: curUserContainer.curUser)
                            categoryContainer.loadLocalCategories()
                        }
                    } label: {
                        Text("Sign Out")
                            .bold()
                    }
                } else {
                    Button {
                        showLoginView = true
                    } label: {
                        Text("Log In")
                            .bold()
                    }
                    .sheet(isPresented: $showLoginView) {
                        LogInView(showLoginView: $showLoginView, showSideWindow: $showSideMenu)
                    }
                    
                }
            }
            
            ScrollView {
                ForEach(Array(categoryContainer.categories.enumerated()), id: \.offset) { index, strElem in
                    HStack {
                        Spacer()
                        CategoryRow(category: $categoryContainer.categories[index], categoryIndex: $categoryIndex, localCategoryIndex: index,delete: {
                            if todoListContainer.selectedCategory == categoryContainer.categories[index] {
                                todoListContainer.selectedCategory = nil
                            }
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
            .transition(.identity)

            Spacer()
            HStack {
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
                        .foregroundColor(.white)
                        .padding(.horizontal, 125)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                Spacer()
            }
            .padding()
            HStack {
                Spacer()
                // Settings button
                Button (action: {
                    UIApplication.shared.endEditing()
                    isShowingSetting = true
                }) {
                    Image(systemName: "gearshape") // SF Symbol for settings
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .padding(.trailing)
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
    
    func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            showSideMenu = false
            return true
        } catch let signOutError_ as NSError {
            print("Error signing out")
            return false
        }
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


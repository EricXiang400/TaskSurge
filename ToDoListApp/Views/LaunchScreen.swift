//
//  LaunchScreen.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 9/23/23.
//

import Foundation
import SwiftUI

struct LaunchScreen: View {
    @State private var isActive = false
    var body: some View {
        VStack {
//            Image(systemName: "trash")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 100, height: 100)
        }
        .background(.white)
        onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isActive = true
            }
        }
        .navigationDestination(isPresented: $isActive) {
            MainView()
        }
    }
}

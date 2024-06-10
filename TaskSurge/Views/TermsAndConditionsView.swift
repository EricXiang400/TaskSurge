//
//  TermsAndConditionsView.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 5/22/24.
//

import Foundation
import SwiftUI

struct TermsAndConditionsView: View {
    @Binding var firstTimeLaunch: Bool
    @State private var agreedToTerms = false
    @State private var showView = false
            
    var body: some View {
        ZStack {
            Color.gray.ignoresSafeArea(.all)
                .opacity(0.4)
                .onTapGesture {
                }
            VStack {
                Spacer()
                HStack {
                    VStack {
                        Button (action: {
                            agreedToTerms.toggle()
                        }) {
                            Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(agreedToTerms ? .blue : .gray)
                        }
                        .padding(.leading)
                        Spacer()
                    }
                    VStack {
                        Text(makeAttributedString())
                            
                        Spacer()
                    }
               }
                .padding(.horizontal)
                .padding(.top)
               .frame(height: 75)
                
                if (agreedToTerms) {
                    Button(action: {
                        withAnimation {
                            showView = false
                            firstTimeLaunch = false
                            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                        }
                        
                    }) {
                        Text("Accept")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                } else {
                    Button(action: {agreedToTerms = false}) {
                        Text("Accept")
                            .padding()
                            .background(Color.blue.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!agreedToTerms)
                }
                Spacer()
            }
            .background(.white)
            .frame(height: 170)
            .cornerRadius(10)
            .padding(.all, 20)
            .offset(y: showView ? 0 : UIScreen.main.bounds.height)
            .animation(.easeInOut(duration: 0.3), value: showView)
        }
        .onAppear {
            withAnimation {
                showView = true
            }
        }
    }
    
    private func makeAttributedString() -> AttributedString {
        var nonTapString: AttributedString = AttributedString("By checking this box, I agree to ")
        
        var termsAndConditions: AttributedString = AttributedString("Terms and Conditions")
        
//        var privacyPolicy: AttributedString = AttributedString(" Privacy Policy")
//        
//        privacyPolicy.link = URL(string: "https://app.termly.io/policy-viewer/policy.html?policyUUID=6e0f3aa4-1c3b-47bc-b643-2e0a5782f803")
        
        termsAndConditions.link = URL(string: "https://app.termly.io/policy-viewer/policy.html?policyUUID=0e8b61b5-aeb8-4cfd-a0a2-4a58a469fd73")
        
        nonTapString.append(termsAndConditions)
        return nonTapString
    }
}

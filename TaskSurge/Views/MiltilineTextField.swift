//
//  MiltilineTextField.swift
//  ToDoListApp
//
//  Created by Eric Xiang on 7/15/23.
//

import Foundation
import SwiftUI
import UIKit

struct MultilineTextView: UIViewRepresentable {
    @Binding var text: String
    var onCommit: () -> Void

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        let parent: MultilineTextView

        init(_ parent: MultilineTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            parent.onCommit()
        }
    }
}

struct MultilineStrikeThroughText: ViewModifier {
    var text: String
    var isStrikedThrough: Bool

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                if isStrikedThrough {
                    Path { path in
                        let lineHeight = geometry.size.height / CGFloat(text.components(separatedBy: "\n").count)
                        path.move(to: CGPoint(x: 0, y: lineHeight / 2))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: lineHeight / 2))
                    }
                    .stroke(Color.red, lineWidth: 2)
                }
                content
            }
        }
    }
}

extension View {
    func multilineStrikeThroughText(text: String, isStrikedThrough: Bool) -> some View {
        self.modifier(MultilineStrikeThroughText(text: text, isStrikedThrough: isStrikedThrough))
    }
}

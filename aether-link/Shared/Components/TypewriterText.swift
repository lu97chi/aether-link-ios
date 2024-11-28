//
//  TypewriterText.swift
//  aether-link
//
//  Created by Luis Roberto Hernandez Robles on 25/11/24.
//

import SwiftUI

struct AnimatedText: View {
    var fullText: String
    @State private var displayedText: String = ""
    @State private var currentIndex: Int = 0

    var body: some View {
        Text(displayedText)
            .font(.headline)
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .onAppear {
                startTyping()
            }
            .onChange(of: fullText) { newValue in
                startTyping()
            }
    }

    private func startTyping() {
        displayedText = ""
        currentIndex = 0
        Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { timer in
            if currentIndex < fullText.count {
                let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
                displayedText += String(fullText[index])
                currentIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
}

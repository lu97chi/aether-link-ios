import SwiftUI

struct TypewriterText: View {
    var fullText: String
    @State private var displayedText: String = ""
    @State private var currentIndex: Int = 0
    @State private var typingTimer: Timer?

    // Customize the typing speed here (seconds per character)
    private let typingSpeed: TimeInterval = 0.1

    var body: some View {
        Text(displayedText)
            .font(.body)
            .foregroundColor(Color("SubtleText"))
            .multilineTextAlignment(.center)
            .onAppear {
                startTyping()
            }
            .onChange(of: fullText) { _ in
                startTyping()
            }
            .onDisappear {
                typingTimer?.invalidate()
            }
    }

    private func startTyping() {
        displayedText = ""
        currentIndex = 0
        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { timer in
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

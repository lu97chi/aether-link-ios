//
//  ActionButton.swift
//  aether-link
//
//  Created by Luis Roberto Hernandez Robles on 18/11/24.
//

import SwiftUI

// MARK: - ActionButton View
struct ActionButton: View {
    var title: String
    var icon: String
    var backgroundColor: Color
    var action: () -> Void
    var isEnabled: Bool
    
    var body: some View {
        Button(action: {
            // Haptic Feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: isEnabled ? [backgroundColor.opacity(0.8), backgroundColor] : [Color.gray.opacity(0.6), Color.gray.opacity(0.4)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .shadow(color: backgroundColor.opacity(0.3), radius: 5, x: 0, y: 2)
        }
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .animation(.spring(), value: isEnabled)
        .accessibility(label: Text(title))
        .disabled(!isEnabled)
    }
}

import SwiftUI

enum ActionButtonStyle {
    case primary
    case secondary
    case danger
}

// MARK: - ActionButton View
struct ActionButton: View {
    var title: String
    var icon: String
    var style: ActionButtonStyle
    var action: () -> Void
    var isEnabled: Bool

    var body: some View {
        // Determine colors based on the button style
        let gradientColors: [Color]
        let textColor: Color = Color("background") // Use white text over colored backgrounds
        let disabledBackground = Color("disabled")
        let disabledTextColor = Color("textSecondary")

        switch style {
        case .primary:
            gradientColors = [Color("primary"), Color("secondaryAccent")]
        case .secondary:
            gradientColors = [Color("secondaryAccent"), Color("primary")]
        case .danger:
            // For 'danger', we can use 'error' color
            gradientColors = [Color("error"), Color("error")]
        }

        return Button(action: {
            // Haptic Feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .fontWeight(.semibold)
                    .font(.headline)
            }
            .foregroundColor(isEnabled ? textColor : disabledTextColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if isEnabled {
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        disabledBackground
                    }
                }
            )
            .cornerRadius(15)
            .shadow(color: isEnabled ? Color.black.opacity(0.2) : Color.clear, radius: 5, x: 0, y: 3)
        }
        .disabled(!isEnabled)
        .scaleEffect(isEnabled ? 1.0 : 0.98)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isEnabled)
        .accessibility(label: Text(title))
    }
}

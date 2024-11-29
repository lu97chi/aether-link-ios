import SwiftUI

enum ActionButtonStyle {
    case primary
    case secondary
    case danger
}

struct ActionButton: View {
    var title: String
    var icon: String
    var style: ActionButtonStyle
    var action: () -> Void
    var isEnabled: Bool

    var body: some View {
        // Determine button appearance
        let gradientColors: [Color]
        let textColor: Color = isEnabled ? Color.white : Color("SubtleText")
        let disabledBackground = Color("Outline")

        switch style {
        case .primary:
            gradientColors = [Color("PrimaryBlue"), Color("SecondaryBlue")]
        case .secondary:
            gradientColors = [Color("SecondaryBlue"), Color("PrimaryBlue")]
        case .danger:
            gradientColors = [Color.red, Color.red.opacity(0.8)] // Adjusted for a darker red
        }

        return Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(textColor)

                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(textColor)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
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
            .cornerRadius(12)
            .shadow(
                color: isEnabled ? Color.black.opacity(0.15) : Color.clear,
                radius: 4,
                x: 0,
                y: 3
            )
        }
        .disabled(!isEnabled)
        .scaleEffect(isEnabled ? 1.0 : 0.98)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isEnabled)
        .accessibility(label: Text(title))
    }
}

import SwiftUI

// MARK: - CircularProgressBar View
struct CircularProgressBar: View {
    var lineWidth: CGFloat = 15
    @Binding var progress: Int // Progress from 0 to 100
    @Binding var operationType: String?

    // State variables for animating progress
    @State private var animatedProgress: CGFloat = 0.0

    // Gradient colors based on operation type
    private var gradientColors: [Color] {
        switch operationType {
        case "Copy":
            return [Color("HighlightCyan"), Color("HighlightCyan").opacity(0.8)]
        case "Delete":
            return [Color.red, Color.red.opacity(0.8)]
        default:
            return [Color("PrimaryBlue"), Color("SecondaryBlue")]
        }
    }

    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(
                    Color("Outline").opacity(0.3),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: 180, height: 180)

            // Foreground Progress Circle
            Circle()
                .trim(from: 0.0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: gradientColors),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(Angle(degrees: -90))
                .frame(width: 180, height: 180)
                .animation(.easeInOut(duration: 0.5), value: animatedProgress)

            // Percentage Text
            VStack {
                Text("\(progress)%")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Color("Text"))
                Text(progress < 100 ? "In Progress" : "Completed")
                    .font(.headline)
                    .foregroundColor(Color("SubtleText"))
            }
        }
        .onAppear {
            updateProgress()
        }
        .onChange(of: progress) { _ in
            updateProgress()
        }
    }

    // MARK: - Helper Methods
    private func updateProgress() {
        // Smoothly animate progress updates
        withAnimation(.easeInOut(duration: 0.5)) {
            animatedProgress = CGFloat(progress) / 100
        }
    }
}

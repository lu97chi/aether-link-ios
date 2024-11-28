import SwiftUI

// MARK: - CircularProgressBar View
struct CircularProgressBar: View {
    var lineWidth: CGFloat = 15
    @Binding var progress: Int // Progress from 0 to 100
    @Binding var operationType: String?

    // State variables for animating progress and glow effect
    @State private var animatedProgress: Double = 0.0
    @State private var glowOpacity: Double = 0.0

    // Determine gradient colors based on operation type
    var gradientColors: [Color] {
        switch operationType {
        case "Copy":
            return [ Color("success").opacity(0.2), Color("success")]
        case "Delete":
            return [Color("error").opacity(0.2), Color("error")]
        default:
            return [Color("primary"), Color("secondaryAccent")]
        }
        
    }

    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(
                    Color("border").opacity(0.3),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: 180, height: 180)

            // Progress Circle with Gradient
            Circle()
                .trim(from: 0.0, to: CGFloat(min(animatedProgress, 1.0)))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: gradientColors),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(Angle(degrees: -90))
                .frame(width: 180, height: 180)
                .overlay(
                    // Glow Effect
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(animatedProgress, 1.0)))
                        .stroke(
                            gradientColors.last?.opacity(0.7) ?? Color("secondaryAccent").opacity(0.7),
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                        )
                        .blur(radius: 10)
                        .opacity(glowOpacity)
                        .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true), value: glowOpacity)
                        .onAppear {
                            glowOpacity = 0.7
                        }
                )
                .animation(.easeInOut(duration: 0.5), value: animatedProgress)

            // Percentage Text
            VStack {
                Text("\(progress)%")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Color("textPrimary"))
                Text("Completed")
                    .font(.headline)
                    .foregroundColor(Color("textSecondary"))
            }
        }
        .onAppear {
            // Initialize the animated progress
            animatedProgress = Double(progress) / 100.0
        }
        .onChange(of: progress) { newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedProgress = Double(newValue) / 100.0
            }
        }
    }
}

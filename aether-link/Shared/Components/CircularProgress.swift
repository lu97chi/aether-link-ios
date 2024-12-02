// CircularProgressBar.swift

import SwiftUI

struct CircularProgressBar: View {
    var lineWidth: CGFloat = 15
    @Binding var progress: Double // Overall progress from 0 to 100
    @Binding var operationType: String? // To adjust gradient based on operation type

    @State private var animatedProgress: CGFloat = 0.0

    private var gradientColors: [Color] {
        switch operationType?.lowercased() {
        case "copy":
            return [Color("HighlightCyan"), Color("HighlightCyan").opacity(0.8)]
        case "delete":
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
                Text("\(Int(progress))%")
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

    private func updateProgress() {
        withAnimation(.easeInOut(duration: 0.5)) {
            animatedProgress = CGFloat(progress) / 100
        }
    }
}

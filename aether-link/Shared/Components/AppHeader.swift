import SwiftUI

// MARK: - AppHeader View
struct AppHeader: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background with gradient and custom wave shape
            WaveShape(yOffset: 0.3)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color("primary"), Color("secondaryAccent")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 250)
                .overlay(
                    WaveShape(yOffset: 0.35)
                        .fill(Color("background").opacity(0.2))
                        .frame(height: 220)
                )
                .overlay(
                    WaveShape(yOffset: 0.4)
                        .fill(Color("background").opacity(0.1))
                        .frame(height: 200)
                )
                .edgesIgnoringSafeArea(.top)

            VStack(spacing: 10) {
                // App Logo or Icon
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(Color("background"))
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)

                // App Title
                Text("AetherLink")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color("background"))
                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 2)

                // Subtitle or Tagline
                Text("Seamless Connectivity")
                    .font(.headline)
                    .foregroundColor(Color("background").opacity(0.85))
            }
            .padding(.bottom, 50)
        }
        .frame(height: 250)
    }
}

// MARK: - Custom Wave Shape
struct WaveShape: Shape {
    var yOffset: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let height = rect.height * yOffset

        path.move(to: CGPoint(x: 0, y: height))

        path.addCurve(
            to: CGPoint(x: rect.width * 0.5, y: height + 40),
            control1: CGPoint(x: rect.width * 0.25, y: height - 20),
            control2: CGPoint(x: rect.width * 0.25, y: height + 60)
        )

        path.addCurve(
            to: CGPoint(x: rect.width, y: height),
            control1: CGPoint(x: rect.width * 0.75, y: height + 20),
            control2: CGPoint(x: rect.width * 0.75, y: height - 40)
        )

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()

        return path
    }
}

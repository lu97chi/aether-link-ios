import SwiftUI

struct CircularProgressBar: View {
    var lineWidth: CGFloat = 15
    var progress: Double // Overall progress from 0 to 100
    var operationType: String? // "copy", "erase"
    var status: String? // "idle", "running", "done", "verifying", "error"

    private var gradientColors: [Color] {
        if let status = status?.lowercased() {
            switch status {
            case "verifying":
                return [Color.green, Color.green.opacity(0.8)]
            case "error":
                return [Color.red, Color.red.opacity(0.8)]
            case "done":
                return [Color.blue, Color.blue.opacity(0.8)]
            default:
                break
            }
        }

        if let operation = operationType?.lowercased() {
            switch operation {
            case "copy":
                return [Color("HighlightCyan"), Color("HighlightCyan").opacity(0.8)]
            case "erase":
                return [Color.red, Color.red.opacity(0.8)]
            default:
                break
            }
        }

        return [Color("PrimaryBlue"), Color("SecondaryBlue")]
    }

    private var displayStatus: String {
        if let status = status?.lowercased() {
            switch status {
            case "idle":
                return "Idle"
            case "running":
                return "Running"
            case "verifying":
                return "Verifying"
            case "done":
                return "Completed"
            case "error":
                return "Error"
            default:
                return "In Progress"
            }
        } else {
            return progress < 100 ? "In Progress" : "Completed"
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

            // Foreground Progress Circle
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress / 100.0, 1.0)))
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(Angle(degrees: -90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            // Percentage Text and Status
            VStack {
                Text("\(Int(progress))%")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Color("Text"))
                Text(displayStatus)
                    .font(.headline)
                    .foregroundColor(Color("SubtleText"))
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

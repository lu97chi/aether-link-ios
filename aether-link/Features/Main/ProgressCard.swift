import SwiftUI

struct ProgressCard: View {
    @Binding var progress: Int
    @Binding var operationType: String?
    @Binding var totalFiles: Int
    @Binding var filesProcessed: Int
    @Binding var currentFileName: String
    @Binding var startTime: Date
    var abortOperation: () -> Void

    // State variables for time calculations
    @State private var elapsedTime: TimeInterval = 0
    @State private var estimatedRemainingTime: TimeInterval = 0
    @State private var timer: Timer?

    @State private var showConfetti = false

    var body: some View {
        ZStack {
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
            }

            VStack(alignment: .center, spacing: 25) {
                // Header with Icon and Operation Type
                HStack(spacing: 15) {
                    Image(systemName: operationIconName())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(operationIconColor())
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(operationType ?? "Operation")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("textPrimary"))

                        Text(progress < 100 ? "In Progress" : "Completed")
                            .font(.subheadline)
                            .foregroundColor(Color("textSecondary"))
                    }
                    Spacer()
                }

                // Circular Progress Indicator with percentage inside
                ZStack {
                    CircularProgressBar(progress: $progress, operationType: $operationType)
                        .frame(width: 160, height: 160)
                }
                .padding(.top, 10)

                // Progress Details Card
                VStack(spacing: 15) {
                    ProgressDetailRow(label: "Files Processed", value: "\(filesProcessed) / \(totalFiles)", systemImage: "doc.on.doc")
                    ProgressDetailRow(label: "Current File", value: currentFileName, systemImage: "doc.text")
                    ProgressDetailRow(label: "Elapsed Time", value: timeString(from: elapsedTime), systemImage: "clock")
                    ProgressDetailRow(label: "Remaining Time", value: timeString(from: estimatedRemainingTime), systemImage: "hourglass.bottomhalf.fill")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color("softBackground"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color("border"), lineWidth: 1)
                )
                .padding(.horizontal)

                // Cancel Button
                if progress < 100 {
                    Button(action: {
                        cancelOperation()
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .font(.headline)
                            Text("Cancel")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(Color("background")) // White text over colored background
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("error")) // Solid red background for cancel button
                        .cornerRadius(12)
                        .shadow(color: Color("error").opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .accessibility(label: Text("Cancel Operation"))
                    .scaleEffect(1.0)
                    .animation(.spring(), value: progress)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color("surface"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color("border"), lineWidth: 1)
            )
            .padding(.horizontal)
            .onAppear {
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
            .onChange(of: progress) { newValue in
                if newValue >= 100 {
                    showConfetti = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showConfetti = false
                    }
                    stopTimer()
                }
                updateEstimatedTime()
            }
            .accessibilityElement(children: .combine)
        }
    }

    // MARK: - Helper Views
    struct ProgressDetailRow: View {
        var label: String
        var value: String
        var systemImage: String

        var body: some View {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(Color("primary"))
                    .frame(width: 20)
                Text(label)
                    .font(.body)
                    .foregroundColor(Color("textSecondary"))
                Spacer()
                Text(value)
                    .font(.body)
                    .foregroundColor(Color("textPrimary"))
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
    }

    // MARK: - Helper Methods
    private func operationIconName() -> String {
        switch operationType {
        case "Copy":
            return "doc.on.doc.fill"
        case "Delete":
            return "trash.fill"
        default:
            return "gearshape.fill"
        }
    }

    private func operationIconColor() -> Color {
        switch operationType {
        case "Copy":
            return Color("primary")
        case "Delete":
            return Color("error")
        default:
            return Color("textSecondary")
        }
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        let ti = Int(timeInterval)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    // MARK: - Timer Methods
    private func startTimer() {
        elapsedTime = Date().timeIntervalSince(startTime)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime = Date().timeIntervalSince(startTime)
            updateEstimatedTime()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateEstimatedTime() {
        guard progress > 0 else {
            estimatedRemainingTime = 0
            return
        }
        let totalEstimatedTime = elapsedTime / Double(progress) * 100
        estimatedRemainingTime = totalEstimatedTime - elapsedTime
    }

    // MARK: - Action Methods
    private func cancelOperation() {
        print("Operation cancelled.")
        abortOperation()
    }
}

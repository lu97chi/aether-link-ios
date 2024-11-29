import SwiftUI

struct ProgressCard: View {
    @Binding var progress: Int
    @Binding var operationType: String?
    @Binding var totalFiles: Int
    @Binding var filesProcessed: Int
    @Binding var currentFileName: String
    @Binding var startTime: Date
    @Binding var messages: [String]
    var abortOperation: () -> Void

    @State private var elapsedTime: TimeInterval = 0
    @State private var estimatedRemainingTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var currentMessage: String = ""

    var body: some View {
        ZStack {
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
                            .foregroundColor(Color("Text"))

                        Text(progress < 100 ? "In Progress" : "Completed")
                            .font(.subheadline)
                            .foregroundColor(Color("SubtleText"))
                    }
                    Spacer()
                }

                // Circular Progress Indicator
                ZStack {
                    CircularProgressBar(progress: $progress, operationType: $operationType)
                        .frame(width: 160, height: 160)
                }
                .padding(.top, 10)

                // Typewriter Text for Messages
                if !messages.isEmpty {
                    TypewriterText(fullText: currentMessage)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .onAppear {
                            updateMessage()
                        }
                        .onChange(of: filesProcessed) { _ in
                            updateMessage()
                        }
                        .onChange(of: messages) { _ in
                            updateMessage()
                        }
                }

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
                        .fill(Color("Background"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color("Outline"), lineWidth: 1)
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
                        .foregroundColor(Color("Background"))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("DangerRed"))
                        .cornerRadius(12)
                        .shadow(color: Color("DangerRed").opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .accessibility(label: Text("Cancel Operation"))
                    .scaleEffect(1.0)
                    .animation(.spring(), value: progress)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color("Surface"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color("Outline"), lineWidth: 1)
            )
            .padding(.horizontal)
            .onAppear {
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
            .onChange(of: progress) { _ in
                updateEstimatedTime()
            }
        }
    }

    // MARK: - Update Messages
    private func updateMessage() {
        guard !messages.isEmpty else {
            currentMessage = ""
            return
        }

        if filesProcessed > 0 && filesProcessed <= messages.count {
            currentMessage = messages[filesProcessed - 1]
        } else {
            currentMessage = messages.first ?? ""
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
            return Color("HighlightCyan")
        case "Delete":
            return Color.red
        default:
            return Color("SubtleText")
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

    private func cancelOperation() {
        abortOperation()
    }
}

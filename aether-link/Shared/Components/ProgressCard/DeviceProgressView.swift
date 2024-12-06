import SwiftUI

struct DeviceProgressView: View {
    var deviceDetail: SocketIOManager.DeviceDetail
    var messages: [String]
    var progress: Double // This should be folder_progress (0.0 to 1.0)

    var body: some View {
        VStack(spacing: 20) {
            // Overall Circular Progress Indicator
            CircularProgressBar(
                progress: deviceDetail.progress,
                operationType: deviceDetail.operationType,
                status: deviceDetail.status
            )
            .frame(width: 160, height: 160)

            // Conditional content based on operationType and status
            if deviceDetail.operationType?.lowercased() == "copy" {
                if deviceDetail.status.lowercased() == "running" {
                    // Current File Progress
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Current File")
                            .font(.headline)
                            .foregroundColor(Color("Text"))

                        Text(URL(fileURLWithPath: deviceDetail.currentFile).lastPathComponent)
                            .font(.subheadline)
                            .foregroundColor(Color("SubtleText"))
                            .lineLimit(1)
                            .truncationMode(.middle)

                        // Individual File Progress
                        ProgressView(value: deviceDetail.fileProgress, total: 100)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color("HighlightCyan")))
                            .accessibility(value: Text("\(Int(deviceDetail.fileProgress)) percent"))
                    }

                    // Progress Details
                    VStack(spacing: 15) {
                        ProgressDetailRow(
                            label: "Files Processed",
                            value: "\(deviceDetail.filesProcessed) of \(deviceDetail.totalFiles)",
                            systemImage: "doc.on.doc"
                        )
                        ProgressDetailRow(
                            label: "Elapsed Time",
                            value: formattedTime(Int(deviceDetail.elapsedTime)),
                            systemImage: "clock"
                        )
                        ProgressDetailRow(
                            label: "Remaining Time",
                            value: formattedTime(Int(deviceDetail.remainingTime)),
                            systemImage: "hourglass.bottomhalf.fill"
                        )
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

                    // Directories Section
                    DirectoriesSection(
                        srcDir: deviceDetail.srcDir,
                        destDir: deviceDetail.destDir
                    )
                    .padding(.top, 10)
                } else if deviceDetail.status.lowercased() == "verifying" {
                    // Progress Logs
                    ProgressLogs(messages: messages, progress: deviceDetail.progress)
                        .padding(.top, 10)
                }
            } else if deviceDetail.operationType?.lowercased() == "erase" {
                // Show minimal information for erase operation
                // For example, only the circular progress bar and percentage
                // Additional UI can be added here if needed
            } else {
                // For other operation types, show default information
            }
        }
    }

    private func formattedTime(_ time: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter.string(from: TimeInterval(time)) ?? "--"
    }
}

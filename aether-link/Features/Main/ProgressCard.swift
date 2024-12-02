// ProgressCard.swift

import SwiftUI

struct ProgressCard: View {
    @EnvironmentObject var socketIOManager: SocketIOManager
    @Binding var messages: [String]
    var abortOperation: () -> Void

    @State private var currentMessage: String = ""
    @State private var showCompletionAlert: Bool = false // State for managing alert visibility

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                // Header with Icon and Operation Type
                HStack(spacing: 15) {
                    Image(systemName: operationIconName())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(operationIconColor())
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(socketIOManager.operationType?.capitalized ?? "Unknown Operation")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("Text"))

                        Text(socketIOManager.progress < 100 ? "In Progress" : "Completed")
                            .font(.subheadline)
                            .foregroundColor(Color("SubtleText"))
                    }
                    Spacer()
                }

                // Overall Circular Progress Indicator
                ZStack {
                    CircularProgressBar(progress: $socketIOManager.progress, operationType: $socketIOManager.operationType)
                        .frame(width: 160, height: 160)
                }

                // Current File Progress
                VStack(alignment: .leading, spacing: 10) {
                    Text("Current File")
                        .font(.headline)
                        .foregroundColor(Color("Text"))

                    Text(URL(fileURLWithPath: socketIOManager.currentFile).lastPathComponent)
                        .font(.subheadline)
                        .foregroundColor(Color("SubtleText"))
                        .lineLimit(1)
                        .truncationMode(.middle)

                    // Individual File Progress
                    ProgressView(value: socketIOManager.fileProgress, total: 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color("HighlightCyan")))
                        .accessibility(value: Text("\(Int(socketIOManager.fileProgress)) percent"))
                }

                // Progress Details
                VStack(spacing: 15) {
                    ProgressDetailRow(
                        label: "Files Processed",
                        value: "\(socketIOManager.filesProcessed) of \(socketIOManager.totalFiles)",
                        systemImage: "doc.on.doc"
                    )
                    ProgressDetailRow(
                        label: "Elapsed Time",
                        value: formattedTime(Int(socketIOManager.elapsedTime)),
                        systemImage: "clock"
                    )
                    ProgressDetailRow(
                        label: "Remaining Time",
                        value: formattedTime(Int(socketIOManager.remainingTime)),
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
                    srcDir: socketIOManager.srcDir,
                    destDir: socketIOManager.destDir
                )
                .padding(.top, 10)

                // Cancel Button
                if socketIOManager.isOperationInProgress {
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
        }
        .alert(isPresented: $showCompletionAlert) {
            Alert(
                title: Text("Operation Completed"),
                message: Text("The \(socketIOManager.operationType?.lowercased() ?? "operation") has completed successfully."),
                dismissButton: .default(Text("OK"))
            )
        }
        .onChange(of: socketIOManager.progress) { progress in
            if progress >= 100 {
                showCompletionAlert = true
            }
        }
    }

    // MARK: - Helper Methods
    private func operationIconName() -> String {
        switch socketIOManager.operationType?.lowercased() {
        case "copy":
            return "doc.on.doc.fill"
        case "delete":
            return "trash.fill"
        default:
            return "gearshape.fill"
        }
    }

    private func operationIconColor() -> Color {
        switch socketIOManager.operationType?.lowercased() {
        case "copy":
            return Color("HighlightCyan")
        case "delete":
            return Color.red
        default:
            return Color("SubtleText")
        }
    }

    private func cancelOperation() {
        abortOperation()
    }

    private func formattedTime(_ time: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter.string(from: TimeInterval(time)) ?? "--"
    }
}

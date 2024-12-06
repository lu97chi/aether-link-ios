import SwiftUI

// MARK: - SocketIOActionsCard View
struct SocketIOActionsCard: View {
    // MARK: - Environment Object
    @EnvironmentObject var socketIOManager: SocketIOManager
    @State private var showDeleteConfirmation: Bool = false // State to show confirmation dialog

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with Title, Devices Connected, and Refresh Button
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Actions")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("Text"))

                    // Devices Connected Info
                    HStack(spacing: 6) {
                        Image(systemName: "externaldrive")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                            .foregroundColor(Color("SubtleText"))

                        Text(devicesConnectedText())
                            .font(.subheadline)
                            .foregroundColor(Color("SubtleText"))
                    }
                }

                Spacer()

                // Refresh Button
                Button(action: {
                    sendMessage(message: "refresh")
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(Color("PrimaryBlue"))
                }
                .disabled(!socketIOManager.isConnected || socketIOManager.isOperationInProgress)
                .accessibilityLabel("Refresh")
                .padding(.trailing, 5)
            }
            .padding(.bottom, 10)

            // Divider
            Divider()

            // Buttons
            HStack(spacing: 20) {
                // Copy Button
                ActionButton(
                    title: "Copy",
                    icon: "doc.on.doc.fill",
                    style: .primary,
                    action: {
                        sendMessage(message: "copy")
                    },
                    isEnabled: socketIOManager.isConnected && !socketIOManager.isOperationInProgress
                )

                // Delete Button
                ActionButton(
                    title: "Erase",
                    icon: "trash.fill",
                    style: .danger,
                    action: {
                        showDeleteConfirmation = true // Show confirmation dialog
                    },
                    isEnabled: socketIOManager.isConnected && !socketIOManager.isOperationInProgress
                )
            }
            .padding(.top, 10)
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color("Surface"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color("Outline"), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.5), value: socketIOManager.isOperationInProgress)
        .confirmationDialog(
            "Are you sure you want to erase?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                sendMessage(message: "erase")
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Helper Methods
    private func devicesConnectedText() -> String {
        let count = socketIOManager.devicesConnected
        if count == 0 {
            return "No devices connected"
        } else if count == 1 {
            return "1 device connected"
        } else {
            return "\(count) devices connected"
        }
    }

    // MARK: - Action Methods
    private func sendMessage(message: String) {
        guard !socketIOManager.isOperationInProgress else { return }
        if message == "refresh" {
            socketIOManager.getDevices()
            return
        }
        socketIOManager.isOperationInProgress = true
        socketIOManager.sendMessage(operationType: message) { success in
            if !success {
                print("Failed to send message.")
            } else {
                print("Message sent successfully.")
            }
        }
    }
}

import SwiftUI

// MARK: - SocketIOActionsCard View
struct SocketIOActionsCard: View {
    // MARK: - Environment Object
    @EnvironmentObject var socketIOManager: SocketIOManager

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            // Title
            Text("Actions")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("textPrimary"))
                .padding(.bottom, 10)
            
            // Buttons
            HStack(spacing: 20) {
                // Copy Button
                ActionButton(
                    title: "Copy",
                    icon: "doc.on.doc.fill",
                    style: .primary,
                    action: {
                        sendMessage(message: "Copy")
                    },
                    isEnabled: socketIOManager.isConnected && !socketIOManager.isOperationInProgress
                )
                                
                // Delete Button
                ActionButton(
                    title: "Delete",
                    icon: "trash.fill",
                    style: .danger,
                    action: {
                        sendMessage(message: "Delete")
                    },
                    isEnabled: socketIOManager.isConnected && !socketIOManager.isOperationInProgress
                )
            }
            .padding(.top, 10)
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color("surface"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color("border"), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.5), value: socketIOManager.isOperationInProgress)
    }
    
    // MARK: - Action Methods
    private func sendMessage(message: String) {
        guard !socketIOManager.isOperationInProgress else { return }
        socketIOManager.isOperationInProgress = true
        socketIOManager.sendMessage(message: message) { success in
            if !success {
                // Handle failure if needed
                print("Failed to send message.")
            } else {
                print("Message sent successfully.")
            }
        }
    }
}

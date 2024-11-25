import SwiftUI
import UIKit

// MARK: - SocketIOActionsCard View
struct SocketIOActionsCard: View {
    // MARK: - Environment Object
    @EnvironmentObject var socketIOManager: SocketIOManager
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title
            Text("Actions")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.bottom, 10)
                .transition(.opacity)
            
            // Buttons
            HStack(spacing: 20) {
                // Copy Button
                ActionButton(
                    title: "Copy",
                    icon: "doc.on.doc",
                    backgroundColor: .blue,
                    action: {
                        sendMessage(message: "Copy")
                        socketIOManager.isOperationInProgress = true
                    },
                    isEnabled: socketIOManager.isConnected && !socketIOManager.isOperationInProgress
                )
                                
                // Delete Button
                ActionButton(
                    title: "Delete",
                    icon: "trash",
                    backgroundColor: .red,
                    action: {
                        sendMessage(message: "Delete")
                        socketIOManager.isOperationInProgress = true
                    },
                    isEnabled: socketIOManager.isConnected && !socketIOManager.isOperationInProgress
                )
            }
            .padding(.top, 10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.cardBackgroundLight, Color.cardBackgroundDark]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .animation(.easeInOut, value: socketIOManager.isOperationInProgress)
    }
    
    // MARK: - Action Methods
    private func sendMessage(message: String) {
        guard !socketIOManager.isOperationInProgress else { return }
        // socketIOManager.isOperationInProgress = true
        socketIOManager.sendMessage(message: message) { success in
            // isOperationInProgress = false
            if !success {
                // Handle failure if needed
                print("Failed to send message.")
            } else {
                print("Message sent successfully.")
            }
        }
    }
}

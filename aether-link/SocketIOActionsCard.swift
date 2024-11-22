//
//  SocketIOActionsCard.swift
//  aether-link
//
//  Created by Luis Roberto Hernandez Robles on 20/11/24.
//

// SocketIOActionsCard.swift

import SwiftUI

struct SocketIOActionsCard: View {
    // MARK: - Environment Object
    @EnvironmentObject var socketIOManager: SocketIOManager
    
    // MARK: - Binding Variable
    @Binding var isOperationInProgress: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Socket.IO Actions")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                // Copy Button
                Button(action: {
                    sendMessage(message: "Copy")
                }) {
                    HStack {
                        Image(systemName: "doc.on.doc")
                            .font(.title2)
                        Text("Copy")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isOperationInProgress ? Color.gray : Color.blue)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .disabled(isOperationInProgress || !socketIOManager.isConnected)
                .accessibility(label: Text("Send Copy via Socket.IO"))
                
                // Delete Button
                Button(action: {
                    sendMessage(message: "Copy")
                }) {
                    HStack {
                        Image(systemName: "trash")
                            .font(.title2)
                        Text("Delete")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isOperationInProgress ? Color.gray : Color.red)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .disabled(isOperationInProgress || !socketIOManager.isConnected)
                .accessibility(label: Text("Send Delete via Socket.IO"))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Action Methods    
    private func sendMessage(message:String) {
        guard !isOperationInProgress else { return }
        isOperationInProgress = true
        socketIOManager.sendMessage(message: message) { success in
            isOperationInProgress = false
            if !success {
                // Handle failure if needed
                print("Failed to send message.")
            } else {
                print("Message sent successfully.")
            }
        }
    }
    
    struct SocketIOActionsCard_Previews: PreviewProvider {
        static var previews: some View {
            SocketIOActionsCard(isOperationInProgress: .constant(false))
                .environmentObject(SocketIOManager())
                .previewLayout(.sizeThatFits)
        }
    }
}

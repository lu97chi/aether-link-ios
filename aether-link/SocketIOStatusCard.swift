//
//  SocketIOStatusCard.swift
//  aether-link
//
//  Created by Luis Roberto Hernandez Robles on 20/11/24.
//

// SocketIOStatusCard.swift

import SwiftUI

struct SocketIOStatusCard: View {
    // MARK: - Environment Object
    @EnvironmentObject var socketIOManager: SocketIOManager
    
    // MARK: - Binding Variable
    @Binding var isOperationInProgress: Bool
    
    // MARK: - Action Closures
    var connectAction: () -> Void
    var disconnectAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 20) {
                // Status Icon
                Image(systemName: socketIOManager.isConnected ? "bolt.circle.fill" : "bolt.slash.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(socketIOManager.isConnected ? .yellow : .gray)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Status Information
                VStack(alignment: .leading, spacing: 5) {
                    Text(socketIOManager.isConnected ? "Socket.IO Connected" : "Socket.IO Disconnected")
                        .font(.headline)
                        .foregroundColor(socketIOManager.isConnected ? .yellow : .gray)
                }
                
                Spacer()
            }
            
            // Connect/Disconnect Button
            if socketIOManager.isConnected {
                Button(action: {
                    disconnectAction()
                }) {
                    HStack {
                        Image(systemName: "arrow.uturn.left.circle.fill")
                            .font(.title2)
                        Text("Disconnect Socket.IO")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .accessibility(label: Text("Disconnect Socket.IO"))
                .disabled(isOperationInProgress)
            } else {
                Button(action: {
                    connectAction()
                }) {
                    HStack {
                        Image(systemName: "bolt.circle.fill")
                            .font(.title2)
                        Text("Connect Socket.IO")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(isOperationInProgress ? Color.gray : Color.blue)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .accessibility(label: Text("Connect to Socket.IO"))
                .disabled(isOperationInProgress)
            }
        }
        .padding()
        .background(Color(.systemBackground)) // Adaptive background for Light/Dark mode
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .animation(.easeInOut, value: socketIOManager.isConnected)
    }
    
    struct SocketIOStatusCard_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                SocketIOStatusCard(
                    isOperationInProgress: .constant(false),
                    connectAction: {},
                    disconnectAction: {}
                )
                .environmentObject(SocketIOManager())
                .previewLayout(.sizeThatFits)
                
                SocketIOStatusCard(
                    isOperationInProgress: .constant(true),
                    connectAction: {},
                    disconnectAction: {}
                )
                .environmentObject(SocketIOManager())
                .previewLayout(.sizeThatFits)
            }
        }
    }
}

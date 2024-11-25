import SwiftUI
import UIKit

// MARK: - SocketIOStatusCard View
struct SocketIOStatusCard: View {
    // MARK: - Environment Object
    @EnvironmentObject var socketIOManager: SocketIOManager
    
    // MARK: - Action Closures
    var connectAction: () -> Void
    var disconnectAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header Section
            HStack {
                StatusIconView(isConnected: socketIOManager.isConnected)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(socketIOManager.isConnected ? "Connected" : "Disconnected")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(socketIOManager.isConnected ? .green : .red)
                        .transition(.opacity)
                    
                    Text(socketIOManager.isConnected ? "Socket.IO is active." : "Awaiting connection.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .transition(.opacity)
                }
                .animation(.easeInOut, value: socketIOManager.isConnected)
                
                Spacer()
            }
            
            // Buttons Section
            Button(action: {
                // Haptic Feedback
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
                if socketIOManager.isConnected {
                    disconnectAction()
                } else {
                    connectAction()
                }
            }) {
                HStack {
                    Image(systemName: socketIOManager.isConnected ? "arrow.uturn.left.circle.fill" : "bolt.circle.fill")
                        .font(.title2)
                    Text(socketIOManager.isConnected ? "Disconnect" : "Connect")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: socketIOManager.isConnected ? [Color.buttonRedStart, Color.buttonRedEnd] : [Color.buttonBlueStart, Color.buttonBlueEnd]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: (socketIOManager.isConnected ? Color.red : Color.blue).opacity(0.3), radius: 5, x: 0, y: 2)
            }
            .scaleEffect(socketIOManager.isOperationInProgress ? 0.95 : 1.0)
            .animation(.spring(), value: socketIOManager.isOperationInProgress)
            .accessibility(label: Text(socketIOManager.isConnected ? "Disconnect Socket.IO" : "Connect to Socket.IO"))
            .disabled(socketIOManager.isOperationInProgress)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: socketIOManager.isConnected ? [Color.connectedGradientStart, Color.connectedGradientEnd] : [Color.disconnectedGradientStart, Color.disconnectedGradientEnd]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .animation(.easeInOut, value: socketIOManager.isOperationInProgress)
    }
}

// MARK: - StatusIconView
struct StatusIconView: View {
    var isConnected: Bool
    @State private var animatePulse = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(isConnected ? Color.connectedGradientStart : Color.disconnectedGradientStart, lineWidth: 5)
                .frame(width: 60, height: 60)
                .shadow(color: isConnected ? Color.green.opacity(0.4) : Color.red.opacity(0.4), radius: 5)
                .scaleEffect(animatePulse ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1).repeatForever(autoreverses: true),
                    value: animatePulse
                )
                .onAppear {
                    animatePulse = true
                }
            
            Image(systemName: isConnected ? "bolt.circle.fill" : "bolt.slash.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(isConnected ? .green : .red)
                .rotationEffect(.degrees(isConnected ? 360 : 0))
                .animation(
                    isConnected ? Animation.linear(duration: 2).repeatForever(autoreverses: false) : .default,
                    value: isConnected
                )
        }
    }
}

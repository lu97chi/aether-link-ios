import SwiftUI

// MARK: - SocketIOStatusCard View
struct SocketIOStatusCard: View {
    // MARK: - Environment Object
    @EnvironmentObject var socketIOManager: SocketIOManager

    // MARK: - Action Closures
    var connectAction: () -> Void
    var disconnectAction: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            // Header Section
            HStack(spacing: 15) {
                StatusIconView(isConnected: socketIOManager.isConnected)
                    .frame(width: 70, height: 70)

                VStack(alignment: .leading, spacing: 5) {
                    Text(socketIOManager.isConnected ? "Connected" : "Disconnected")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("Text"))
                        .transition(.opacity)

                    Text(socketIOManager.isConnected ? "Socket.IO is active." : "Awaiting connection.")
                        .font(.body)
                        .foregroundColor(Color("SubtleText"))
                        .transition(.opacity)
                }
                .animation(.easeInOut(duration: 0.5), value: socketIOManager.isConnected)

                Spacer()
            }

            // Button Section
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
                    Image(systemName: socketIOManager.isConnected ? "wifi.slash" : "wifi")
                        .font(.headline)
                    Text(socketIOManager.isConnected ? "Disconnect" : "Connect")
                        .fontWeight(.semibold)
                        .font(.headline)
                }
                .foregroundColor(Color("Background")) // White text over colored background
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: socketIOManager.isConnected ? [Color("DangerRed"), Color("DangerRed")] : [Color("PrimaryBlue"), Color("SecondaryBlue")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(15)
                .shadow(color: (socketIOManager.isConnected ? Color("DangerRed") : Color("PrimaryBlue")).opacity(0.4), radius: 5, x: 0, y: 3)
            }
            .disabled(socketIOManager.isOperationInProgress)
            .scaleEffect(socketIOManager.isOperationInProgress ? 0.95 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: socketIOManager.isOperationInProgress)
            .accessibility(label: Text(socketIOManager.isConnected ? "Disconnect Socket.IO" : "Connect to Socket.IO"))
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
    }
}

// MARK: - StatusIconView
struct StatusIconView: View {
    var isConnected: Bool
    @State private var animatePulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: isConnected ? [Color("HighlightCyan"), Color("HighlightCyan")] : [Color("DangerRed"), Color("DangerRed")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: isConnected ? Color("HighlightCyan").opacity(0.3) : Color("DangerRed").opacity(0.3), radius: 10, x: 0, y: 5)
                .scaleEffect(animatePulse ? 1.05 : 1.0)
                .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: animatePulse)
                .onAppear {
                    animatePulse = true
                }

            Image(systemName: isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
                .foregroundColor(Color("Background")) // White icon over colored circle
        }
    }
}

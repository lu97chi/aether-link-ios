import SwiftUI

struct SocketIOView: View {
    @EnvironmentObject var socketIOManager: SocketIOManager
    @State private var showProgressCard: Bool = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                AppHeader()
                    .frame(height: 40)
                    .edgesIgnoringSafeArea(.top)

                ScrollView {
                    VStack(spacing: 30) {
                        SocketIOStatusCard(
                            connectAction: { socketIOManager.connect() },
                            disconnectAction: { socketIOManager.disconnect() }
                        )
                        .environmentObject(socketIOManager)

                        SocketIOActionsCard()
                            .environmentObject(socketIOManager)

                        // ProgressView for initial state
                        if socketIOManager.isOperationInProgress && socketIOManager.devicesDetails.isEmpty {
                            ProgressView(socketIOManager.statusMessage)
                                .progressViewStyle(CircularProgressViewStyle(tint: Color("PrimaryBlue")))
                                .padding(.top, 10)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                                .animation(.easeInOut(duration: 0.5), value: socketIOManager.isOperationInProgress)
                        }
                    }
                    .padding(.top, 20)
                }
            }

            // ProgressCard Modal with Blur Effect
            if showProgressCard {
                ZStack {
                    // Background blur
                    BlurView(style: .systemMaterialDark)
                        .edgesIgnoringSafeArea(.all)
                        .opacity(0.9)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.7), value: showProgressCard)

                    // ProgressCard
                    ProgressCard(
                        abortOperation: socketIOManager.sendCancel
                    )
                    .environmentObject(socketIOManager)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                    .animation(.spring(response: 0.8, dampingFraction: 0.8), value: showProgressCard)
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            updateProgressCardVisibility()
        }
        .onChange(of: socketIOManager.isOperationInProgress) { _ in
            updateProgressCardVisibility()
        }
    }

    // MARK: - Helper Methods
    private func updateProgressCardVisibility() {
        withAnimation {
            // Show ProgressCard when operation is in progress
            showProgressCard = socketIOManager.isOperationInProgress
        }
    }
}

// SocketIOView.swift

import SwiftUI

struct SocketIOView: View {
    @EnvironmentObject var socketIOManager: SocketIOManager
    @State private var showProgressCard: Bool = false
    @State private var messages: [String] = ["Initializing..."]

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
                        if socketIOManager.progress == 0 && socketIOManager.isOperationInProgress {
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
                        messages: $messages,
                        abortOperation: socketIOManager.sendCancel
                    )
                    .padding()
                    .scaleEffect(showProgressCard ? 1.0 : 0.9)
                    .opacity(showProgressCard ? 1 : 0)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                    .animation(.spring(response: 0.8, dampingFraction: 0.8), value: showProgressCard)
                }
            }
        }
        .onAppear {
            // Load messages dynamically based on the operation type
            if let operationType = socketIOManager.operationType {
                messages = getMessagesByType(operationType: operationType)
            }
        }
        .onChange(of: socketIOManager.operationType) { newType in
            messages = getMessagesByType(operationType: newType ?? "default")
        }
        .onChange(of: socketIOManager.progress) { _ in
            updateProgressCardVisibility()
        }
        .onChange(of: socketIOManager.fileProgress) { _ in
            updateProgressCardVisibility()
        }
        .onChange(of: socketIOManager.isOperationInProgress) { _ in
            updateProgressCardVisibility()
        }
    }

    // MARK: - Helper Methods
    private func updateProgressCardVisibility() {
        withAnimation {
            // Show ProgressCard only when operation is in progress and overall progress > 0
            showProgressCard = socketIOManager.isOperationInProgress && socketIOManager.progress > 0
            if showProgressCard && messages.isEmpty {
                messages = getMessagesByType(operationType: socketIOManager.operationType ?? "default")
            }
        }
    }
}

func getMessagesByType(operationType: String) -> [String] {
    switch operationType.lowercased() {
    case "copy":
        return [
            "Initializing the copy operation...",
            "Scanning the source directory...",
            "Preparing to copy files...",
            "Starting to copy the first batch...",
            "Copying file 1 of 10...",
            "Copying file 5 of 10...",
            "File integrity check in progress...",
            "Optimizing copied files...",
            "Finalizing the copy operation...",
            "All files have been successfully copied!",
            "Operation completed without errors."
        ]

    case "delete":
        return [
            "Initializing the delete operation...",
            "Scanning for files to delete...",
            "Identifying unused or temporary files...",
            "Preparing the first batch of files for deletion...",
            "Deleting file 1 of 15...",
            "Deleting file 7 of 15...",
            "Ensuring safe deletion protocols...",
            "Verifying files are unrecoverable...",
            "Optimizing storage space after deletion...",
            "Finalizing the delete operation...",
            "All selected files have been safely deleted!",
            "Operation completed without errors."
        ]

    default:
        return [
            "Starting the operation...",
            "Performing the required tasks...",
            "Optimizing the process...",
            "Finalizing the operation...",
            "Operation completed successfully!"
        ]
    }
}

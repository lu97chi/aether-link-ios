//
//  SocketIOView.swift
//  aether-link
//
//  Created by Luis Roberto Hernandez Robles on 28/11/24.
//

import SwiftUI

struct SocketIOView: View {
    @EnvironmentObject var socketIOManager: SocketIOManager

    var body: some View {
        VStack(spacing: 0) {
            // App Header
            AppHeader()
                .frame(height: 250)
                .edgesIgnoringSafeArea(.top)

            // Scrollable content
            ScrollView {
                VStack(spacing: 30) {
                    // SocketIO Status Card
                    SocketIOStatusCard(
                        connectAction: {
                            socketIOManager.connect()
                        },
                        disconnectAction: {
                            socketIOManager.disconnect()
                        }
                    )
                    .environmentObject(socketIOManager)

                    // Actions Card
                    SocketIOActionsCard()
                        .environmentObject(socketIOManager)

                    // Progress views
                    if socketIOManager.progress == 0 && socketIOManager.isOperationInProgress {
                        ProgressView(socketIOManager.receivedMessage ?? "Processing...")
                            .progressViewStyle(CircularProgressViewStyle(tint: Color("primary")))
                            .padding(.top, 10)
                            .transition(.scale)
                            .animation(.easeInOut, value: socketIOManager.isOperationInProgress)
                    }

                    if socketIOManager.progress > 0 && socketIOManager.isOperationInProgress{
                        ProgressCard(
                                    progress:.constant(socketIOManager.progress),
                                    operationType:.constant(socketIOManager.operationType),
                                    totalFiles:.constant(socketIOManager.totalFiles),
                                    filesProcessed: .constant(socketIOManager.filesProcessed),
                                    currentFileName: .constant(socketIOManager.currentFileName),
                                    startTime: .constant(socketIOManager.startTime),
                                    abortOperation: socketIOManager.sendCancel
                                )
                    }

                    Spacer()
                }
                .padding(.top, 20)
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}

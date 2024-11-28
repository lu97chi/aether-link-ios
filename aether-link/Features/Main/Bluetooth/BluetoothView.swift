//
//  BluetoothView.swift
//  aether-link
//
//  Created by Luis Roberto Hernandez Robles on 28/11/24.
//

import SwiftUI

struct BluetoothView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @State private var isShowingDeviceList = false
    @State private var isOperationInProgress = false
    @State private var progress: Int = 0
    @State private var operationType: String? = nil
    @State private var showCompletionAlert = false
    @State private var completionMessage = ""

    var body: some View {
        VStack(spacing: 0) {
            // App Header (if you have one for BluetoothView)
            AppHeader()
                .frame(height: 250)
                .edgesIgnoringSafeArea(.top)

            ScrollView {
                VStack(spacing: 30) {
                    // Connection Status Card
                    ConnectionStatusCard(
                        isOperationInProgress: $isOperationInProgress,
                        connectAction: {
                            bluetoothManager.startScanning()
                            isShowingDeviceList = true
                        },
                        disconnectAction: {
                            bluetoothManager.disconnect()
                        }
                    )
                    .padding(.horizontal)

                    // Bluetooth Actions Card
                    BluetoothActionsCard(
                        isShowingDeviceList: $isShowingDeviceList,
                        isOperationInProgress: $isOperationInProgress,
                        startOperation: startBluetoothOperation
                    )
                    .padding(.horizontal)

                    // Progress views
//                    if isOperationInProgress {
//                        ProgressCard(
//                            progress: $progress,
//                            operationType: $operationType,
//                            abortOperation: {
//                                // Implement abort operation logic
//                            }
//                        )
//                        .padding(.horizontal)
//                        .transition(.slide)
//                    }

                    Spacer()
                }
                .padding(.top, 20)
                .sheet(isPresented: $isShowingDeviceList) {
                    DeviceListView()
                        .environmentObject(bluetoothManager)
                }
                .alert(isPresented: $showCompletionAlert) {
                    Alert(
                        title: Text("Operation Completed"),
                        message: Text(completionMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
    }

    func startBluetoothOperation(type: String) {
        operationType = type
        isOperationInProgress = true
        progress = 0
        bluetoothManager.sendMessage(action: type)
    }
}

import SwiftUI

struct MainView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @EnvironmentObject var socketIOManager: SocketIOManager

    var body: some View {
        TabView {
            // Socket.IO Tab
            SocketIOView()
                .tabItem {
                    Label("Socket.IO", systemImage: "network")
                }
                .environmentObject(socketIOManager)
            
            // Bluetooth Tab
            BluetoothView()
                .tabItem {
                    Label("Bluetooth", systemImage: "dot.radiowaves.left.and.right")
                }
                .environmentObject(bluetoothManager)
        }
        .accentColor(.blue) // Customize the tab highlight color
    }
}

struct BluetoothView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @State private var isShowingDeviceList = false
    @State private var isOperationInProgress = false
    @State private var progress: Int = 0
    @State private var operationType: String? = nil
    @State private var showCompletionAlert = false
    @State private var completionMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
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

                BluetoothActionsCard(
                    isShowingDeviceList: $isShowingDeviceList,
                    isOperationInProgress: $isOperationInProgress,
                    startOperation: startBluetoothOperation
                )
                .padding(.horizontal)

                if isOperationInProgress {
                    //ProgressCard(progress: $progress, operationType: $operationType, abortOperation: <#T##Binding<() -> Void>#>)
                      //  .padding(.horizontal)
                       // .transition(.slide)
                }

                Spacer()
            }
            .padding(.top)
            .sheet(isPresented: $isShowingDeviceList) {
                DeviceListView()
                    .environmentObject(bluetoothManager)
            }
            .alert(isPresented: $showCompletionAlert) {
                Alert(title: Text("Operation Completed"),
                      message: Text(completionMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
    }

    func startBluetoothOperation(type: String) {
        operationType = type
        isOperationInProgress = true
        progress = 0
        simulateOperation()
        bluetoothManager.sendMessage(action: type)
    }

    func simulateOperation() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if progress < 1 {
                progress += 10
            } else {
                timer.invalidate()
                isOperationInProgress = false
                completionMessage = "\(operationType?.capitalized ?? "Operation") completed successfully."
                showCompletionAlert = true
                operationType = nil
                progress = 0
            }
        }
    }
}

struct SocketIOView: View {
    @EnvironmentObject var socketIOManager: SocketIOManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                SocketIOStatusCard(
                    connectAction: {
                        socketIOManager.connect()
                    },
                    disconnectAction: {
                        socketIOManager.disconnect()
                    }
                )
                .padding(.horizontal)
                
                SocketIOActionsCard()
                    .padding(.horizontal)
                
                
                if socketIOManager.progress == 0 && (socketIOManager.isOperationInProgress) == true {
                    ProgressView(socketIOManager.receivedMessage ?? "Processing...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .padding(.top, 10)
                        .transition(.scale)
                        .animation(.easeInOut, value: (socketIOManager.isOperationInProgress))
                }
                
                if socketIOManager.progress > 0 {
                    ProgressCard(
                        progress: .constant(socketIOManager.progress),
                        operationType: .constant(socketIOManager.operationType),
                        abortOperation: socketIOManager.sendCancel
                    )
                }
            }
        }
    }
}

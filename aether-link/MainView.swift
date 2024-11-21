// MainView.swift

import SwiftUI

struct MainView: View {
    // MARK: - Environment Objects
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @EnvironmentObject var socketIOManager: SocketIOManager
    
    // MARK: - State Variables
    @State private var isShowingDeviceList = false
    @State private var isOperationInProgress = false
    @State private var operationType: String? = nil // "copy" or "delete"
    @State private var progress: Float = 0.0
    @State private var showCompletionAlert = false
    @State private var completionMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header with App Title and Logo
                headerView
                
                // Bluetooth Connection Status Card
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
                
                // Socket.IO Connection Status Card
                SocketIOStatusCard(
                    isOperationInProgress: $isOperationInProgress,
                    connectAction: {
                        socketIOManager.connect()
                    },
                    disconnectAction: {
                        socketIOManager.disconnect()
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
                
                // Socket.IO Actions Card
                SocketIOActionsCard(
                    isOperationInProgress: $isOperationInProgress
                )
                .padding(.horizontal)
                
                // Progress Card
                if isOperationInProgress {
                    ProgressCard(progress: $progress, operationType: $operationType)
                        .padding(.horizontal)
                        .transition(.slide)
                }
                
                // Socket.IO Message Display
                if let message = socketIOManager.receivedMessage {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Socket.IO Message:")
                            .font(.headline)
                        Text(message)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .transition(.opacity)
                }
                
                Spacer()
            }
            .padding(.top)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            )
            .navigationBarHidden(true)
            .alert(isPresented: $showCompletionAlert) {
                Alert(title: Text("Operation Completed"),
                      message: Text(completionMessage),
                      dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: Binding<Bool>(
                get: { bluetoothManager.errorMessage != nil || socketIOManager.errorMessage != nil },
                set: { _ in
                    bluetoothManager.errorMessage = nil
                    socketIOManager.errorMessage = nil
                }
            )) {
                Alert(title: Text("Error"),
                      message: Text(bluetoothManager.errorMessage ?? socketIOManager.errorMessage ?? "Unknown Error"),
                      dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $isShowingDeviceList) {
                DeviceListView()
                    .environmentObject(bluetoothManager)
            }
            .animation(.easeInOut, value: isOperationInProgress)
        }
    }
    
    // MARK: - Header View
    var headerView: some View {
        HStack {
            Image(systemName: "link.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.blue)
                .padding(.leading, 20)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Welcome to")
                    .font(.title2)
                    .foregroundColor(.gray)
                Text("Aetherlink")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
    }
    
    // MARK: - Operation Handling
    
    // Bluetooth-specific operation
    func startBluetoothOperation(type: String) {
        operationType = type
        isOperationInProgress = true
        progress = 0.0
        simulateOperation()
        
        // Example: Send a message via Bluetooth
        bluetoothManager.sendMessage(action: type)
    }
    
    func simulateOperation() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if progress < 1.0 {
                progress += 0.01
            } else {
                timer.invalidate()
                isOperationInProgress = false
                completionMessage = "\(operationType?.capitalized ?? "Operation") completed successfully."
                showCompletionAlert = true
                operationType = nil
                progress = 0.0
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(BluetoothManager())
            .environmentObject(SocketIOManager())
    }
}

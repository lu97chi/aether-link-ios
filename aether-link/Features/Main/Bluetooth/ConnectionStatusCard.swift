// ConnectionStatusCard.swift

import SwiftUI

struct ConnectionStatusCard: View {
    // MARK: - Environment Object
    @EnvironmentObject var bluetoothManager: BluetoothManager
    
    // MARK: - Binding Variable
    @Binding var isOperationInProgress: Bool
    
    // MARK: - Action Closures
    var connectAction: () -> Void
    var disconnectAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 20) {
                // Status Icon
                Image(systemName: bluetoothManager.isConnected ? "checkmark.circle.fill" : "xmark.octagon.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(bluetoothManager.isConnected ? .green : .red)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Status Information
                VStack(alignment: .leading, spacing: 5) {
                    Text(bluetoothManager.isConnected ? "Connected" : "Not Connected")
                        .font(.headline)
                        .foregroundColor(bluetoothManager.isConnected ? .green : .red)
                    
                    if bluetoothManager.isConnected {
                        Text(bluetoothManager.isReadyToSend ? "Ready to Send" : "Preparing to Send")
                            .font(.subheadline)
                            .foregroundColor(bluetoothManager.isReadyToSend ? .blue : .orange)
                    }
                }
                
                Spacer()
            }
            
            // Connect/Disconnect Button
            if bluetoothManager.isConnected {
                Button(action: {
                    disconnectAction()
                }) {
                    HStack {
                        Image(systemName: "arrow.uturn.left.circle.fill")
                            .font(.title2)
                        Text("Disconnect Bluetooth")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .accessibility(label: Text("Disconnect Bluetooth"))
                .disabled(isOperationInProgress)
            } else {
                Button(action: {
                    connectAction()
                }) {
                    HStack {
                        Image(systemName: "wifi.circle.fill")
                            .font(.title2)
                        Text("Connect Bluetooth")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(isOperationInProgress ? Color.gray : Color.blue)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .accessibility(label: Text("Connect Bluetooth"))
                .disabled(isOperationInProgress)
            }
        }
        .padding()
        .background(Color(.systemBackground)) // Adaptive background for Light/Dark mode
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .animation(.easeInOut, value: bluetoothManager.isConnected)
    }
    
    struct ConnectionStatusCard_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                ConnectionStatusCard(
                    isOperationInProgress: .constant(false),
                    connectAction: {},
                    disconnectAction: {}
                )
                .environmentObject(BluetoothManager())
                .previewLayout(.sizeThatFits)
                
                ConnectionStatusCard(
                    isOperationInProgress: .constant(true),
                    connectAction: {},
                    disconnectAction: {}
                )
                .environmentObject(BluetoothManager())
                .previewLayout(.sizeThatFits)
            }
        }
    }
}

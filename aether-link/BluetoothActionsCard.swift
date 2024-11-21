// ActionsCard.swift

import SwiftUI

struct BluetoothActionsCard: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @Binding var isShowingDeviceList: Bool
    @Binding var isOperationInProgress: Bool
    var startOperation: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Actions")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 20) {
                // Copy Action
                Button(action: {
                    startOperation("copy")
                }) {
                    HStack {
                        Image(systemName: "doc.on.doc.fill")
                            .font(.title2)
                        Text("Copy")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(bluetoothManager.isReadyToSend ? Color.blue : Color.gray)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .disabled(!bluetoothManager.isReadyToSend || isOperationInProgress)
                
                // Delete Action
                Button(action: {
                    startOperation("delete")
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .font(.title2)
                        Text("Delete")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(bluetoothManager.isReadyToSend ? Color.red : Color.gray)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .disabled(!bluetoothManager.isReadyToSend || isOperationInProgress)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct ActionsCard_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothActionsCard(isShowingDeviceList: .constant(false), isOperationInProgress: .constant(false), startOperation: { _ in })
            .environmentObject(BluetoothManager())
            .previewLayout(.sizeThatFits)
    }
}

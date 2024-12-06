import SwiftUI

struct ProgressCard: View {
    @EnvironmentObject var socketIOManager: SocketIOManager
    var abortOperation: () -> Void

    @State private var showCompletionAlert: Bool = false
    @State private var selectedDeviceIndex: Int = 0

    // Static messages array declared as a constant
    private let messages: [String] = [
        "Initializing the verification process...",
        "Scanning files for integrity checks...",
        "Cross-checking file hashes...",
        "Finalizing verification...",
        "Verification completed successfully!"
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // Header with Icon and Operation Type
                HeaderView(
                    operationType: socketIOManager.operationType,
                    isOperationInProgress: socketIOManager.isOperationInProgress
                )

                // Device Tabs
                if socketIOManager.devicesDetails.count > 1 {
                    let deviceLabels = socketIOManager.devicesDetails.map { $0.srcDir }
                    DevicePickerView(selectedDeviceIndex: $selectedDeviceIndex, deviceLabels: deviceLabels)
                }

                // Get the data for the selected device
                if socketIOManager.devicesDetails.indices.contains(selectedDeviceIndex) {
                    let deviceDetail = socketIOManager.devicesDetails[selectedDeviceIndex]

                    DeviceProgressView(
                        deviceDetail: deviceDetail,
                        messages: messages,
                        progress: deviceDetail.progress // 0.0 to 100.0
                    )
                    .transition(.slide) // Add transition for animation
                } else {
                    Text("No data available for this device.")
                        .foregroundColor(Color("SubtleText"))
                }

                // Cancel Button
                if socketIOManager.isOperationInProgress {
                    CancelButtonView(abortOperation: abortOperation)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color("Surface"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color("Outline"), lineWidth: 1)
            )
            .padding(.horizontal)
            // Attach DragGesture here
            .gesture(
                DragGesture()
                    .onEnded { value in
                        let horizontalAmount = value.translation.width
                        if abs(horizontalAmount) < 50 { return } // Ignore small swipes

                        if horizontalAmount < 0 {
                            // Swipe Left: Next Tab
                            if selectedDeviceIndex < socketIOManager.devicesDetails.count - 1 {
                                withAnimation(.easeInOut) {
                                    selectedDeviceIndex += 1
                                }
                            }
                        } else {
                            // Swipe Right: Previous Tab
                            if selectedDeviceIndex > 0 {
                                withAnimation(.easeInOut) {
                                    selectedDeviceIndex -= 1
                                }
                            }
                        }
                    }
            )
        }
        .alert(isPresented: $showCompletionAlert) {
            Alert(
                title: Text("Operation Completed"),
                message: Text("The \(socketIOManager.operationType?.lowercased() ?? "operation") has completed successfully."),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            // Initial setup if needed
        }
        .onChange(of: socketIOManager.devicesDetails) { _ in
            // Update the selected device index if needed
            if selectedDeviceIndex >= socketIOManager.devicesDetails.count {
                selectedDeviceIndex = 0
            }
        }
        .onChange(of: socketIOManager.isOperationInProgress) { inProgress in
            if !inProgress {
                showCompletionAlert = true
            }
        }
    }
}

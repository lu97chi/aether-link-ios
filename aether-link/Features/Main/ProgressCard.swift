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
                    // Use 'label' instead of 'srcDir' for friendly names
                    let deviceLabels = socketIOManager.devicesDetails.map { $0.srcDir }
                    DevicePickerView(selectedDeviceIndex: $selectedDeviceIndex, deviceLabels: deviceLabels)
                        .transition(.opacity) // Smooth transition for device tabs
                } else if socketIOManager.devicesDetails.count == 1 {
                    // If only one device, display its label directly
                    Text(socketIOManager.devicesDetails.first?.srcDir ?? "Device")
                        .font(.headline)
                        .padding()
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
                    .onChange(of: deviceDetail.progress) { newValue in
                        if newValue >= 100.0 {
                            moveToNextTab()
                        }
                    }
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
            // Automatically select the first device if available
            if !socketIOManager.devicesDetails.isEmpty {
                selectedDeviceIndex = 0
            }
        }
        .onChange(of: socketIOManager.devicesDetails) { newDevices in
            // If devices are updated (e.g., upon detection), reset selectedDeviceIndex if out of bounds
            if selectedDeviceIndex >= newDevices.count {
                selectedDeviceIndex = max(0, newDevices.count - 1)
            }
        }
        .onChange(of: socketIOManager.isOperationInProgress) { inProgress in
            if !inProgress && socketIOManager.status.lowercased() == "done" {
                showCompletionAlert = true
            }
        }
    }

    // MARK: - Move to Next Tab Function
    private func moveToNextTab() {
        if selectedDeviceIndex < socketIOManager.devicesDetails.count - 1 {
            withAnimation(.easeInOut) {
                selectedDeviceIndex += 1
            }
        } else {
            print("✅ All devices have completed their operations.")
            // Optionally, you can reset to the first device or perform another action
            // For example, reset to the first device:
            // withAnimation(.easeInOut) {
            //     selectedDeviceIndex = 0
            // }
            // Or trigger a final completion alert
        }
    }
}


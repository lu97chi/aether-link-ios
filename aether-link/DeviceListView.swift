// DeviceListView.swift

import SwiftUI
import CoreBluetooth

struct DeviceListView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if bluetoothManager.discoveredPeripherals.isEmpty {
                    // Empty State View
                    emptyStateView
                } else {
                    // Device List
                    List(filteredPeripherals) { device in
                        DeviceRowView(device: device, isTarget: isTargetDevice(device))
                            .onTapGesture {
                                bluetoothManager.connectToPeripheral(device.peripheral)
                                presentationMode.wrappedValue.dismiss()
                            }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationBarTitle("Available Devices", displayMode: .inline)
            .navigationBarItems(
                leading: scanButton,
                trailing: doneButton
            )
            .searchable(text: $searchText, prompt: "Search Devices")
        }
    }
    
    // MARK: - Subviews
    
    /// View displayed when no devices are found.
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            
            Text("No Devices Found")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text("Ensure your device is discoverable and try scanning again.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                bluetoothManager.startScanning()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise.circle.fill")
                    Text("Scan Again")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
            }
        }
        .padding()
    }
    
    /// Scan Button
    private var scanButton: some View {
        Button(action: {
            bluetoothManager.startScanning()
        }) {
            HStack {
                Image(systemName: "arrow.clockwise.circle.fill")
                Text("Scan")
            }
        }
    }
    
    /// Done Button
    private var doneButton: some View {
        Button("Done") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    // MARK: - Helper Methods
    
    /// Filters peripherals based on the search text.
    private var filteredPeripherals: [DiscoveredPeripheral] {
        if searchText.isEmpty {
            return bluetoothManager.discoveredPeripherals
        } else {
            return bluetoothManager.discoveredPeripherals.filter { device in
                device.name.lowercased().contains(searchText.lowercased()) ||
                device.manufacturerData?.lowercased().contains(searchText.lowercased()) == true ||
                device.serviceUUIDs.contains(where: { $0.uuidString.lowercased().contains(searchText.lowercased()) })
            }
        }
    }
    
    /// Determines if the given device matches the target Raspberry Pi based on manufacturer data or service UUIDs.
    /// - Parameter device: The discovered peripheral.
    /// - Returns: A Boolean indicating if it's the target device.
    private func isTargetDevice(_ device: DiscoveredPeripheral) -> Bool {
        // Implement your logic to identify target devices.
        // For example, based on specific service UUIDs or manufacturer data.
        // Currently returning false as a placeholder.
        return false
    }
}

// MARK: - DeviceRowView

struct DeviceRowView: View {
    let device: DiscoveredPeripheral
    let isTarget: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            // Device Icon
            Image(systemName: "antenna.radiowaves.left.and.right.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(isTarget ? .blue : .gray)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Device Information
            VStack(alignment: .leading, spacing: 5) {
                Text(device.name)
                    .font(.headline)
                    .foregroundColor(isTarget ? .blue : .primary)
                Text("RSSI: \(device.rssi)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let manufacturerData = device.manufacturerData {
                    Text("Manufacturer: \(manufacturerData)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                if !device.serviceUUIDs.isEmpty {
                    Text("Services: \(device.serviceUUIDs.map { $0.uuidString }.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                if !device.serviceData.isEmpty {
                    Text("Service Data:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    ForEach(Array(device.serviceData.keys), id: \.self) { uuid in
                        Text("\(uuid.uuidString): \(device.serviceData[uuid] ?? "")")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                
                if let txPower = device.txPowerLevel {
                    Text("TX Power: \(txPower)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Connection Indicator
            if isTarget {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 5)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct DeviceListView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceListView()
            .environmentObject(BluetoothManager())
    }
}

// BluetoothManager.swift

import Foundation
import CoreBluetooth
import CryptoKit // If using encryption

// MARK: - BluetoothManager Class
class BluetoothManager: NSObject, ObservableObject {
    // MARK: - Properties
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    
    @Published var discoveredPeripherals: [DiscoveredPeripheral] = []
    @Published var isConnected: Bool = false
    @Published var isReadyToSend: Bool = false
    @Published var isScanning: Bool = false
    @Published var errorMessage: String? = nil
    
    private var writeCharacteristic: CBCharacteristic?
    
    // MARK: - Initializer
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Scanning Methods
    
    /// Starts scanning for all available Bluetooth peripherals.
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            print("Cannot start scanning: Bluetooth is not powered on.")
            DispatchQueue.main.async {
                self.errorMessage = "Bluetooth is not powered on."
            }
            return
        }
        
        // Clear previously discovered peripherals
        DispatchQueue.main.async {
            self.discoveredPeripherals.removeAll()
        }
        // Start scanning for all devices without filtering by service UUIDs
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        DispatchQueue.main.async {
            self.isScanning = true
        }
        print("Started scanning for peripherals.")
        
        // Stop scanning after 10 seconds to conserve resources
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.stopScanning()
        }
    }
    
    /// Stops scanning for Bluetooth peripherals.
    func stopScanning() {
        centralManager.stopScan()
        DispatchQueue.main.async {
            self.isScanning = false
        }
        print("Stopped scanning for peripherals.")
    }
    
    // MARK: - Connection Methods
    
    /// Connects to the selected peripheral.
    /// - Parameter peripheral: The CBPeripheral to connect to.
    func connectToPeripheral(_ peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        stopScanning()
        centralManager.connect(peripheral, options: nil)
        print("Attempting to connect to \(peripheral.name ?? "device").")
    }
    
    /// Disconnects from the currently connected peripheral.
    func disconnect() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
            print("Disconnecting from \(peripheral.name ?? "device").")
        }
    }
    
    // MARK: - Data Transmission Methods
    
    /// Sends a JSON-formatted message to the connected peripheral.
    /// - Parameter action: The action to include in the message (e.g., "copy", "erase").
    func sendMessage(action: String) {
        guard let peripheral = connectedPeripheral, let characteristic = writeCharacteristic else {
            print("Peripheral or characteristic not available.")
            DispatchQueue.main.async {
                self.errorMessage = "Cannot send message. Not connected or characteristic unavailable."
            }
            return
        }
        
        let message = Message(action: action)
        do {
            let jsonData = try JSONEncoder().encode(message)
            peripheral.writeValue(jsonData, for: characteristic, type: .withResponse)
            print("Sent message: \(message)")
        } catch {
            print("Error encoding message: \(error)")
            DispatchQueue.main.async {
                self.errorMessage = "Failed to encode message."
            }
        }
    }
}

// MARK: - CBCentralManagerDelegate

extension BluetoothManager: CBCentralManagerDelegate {
    /// Called when the central manager's state is updated.
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("Bluetooth state is UNKNOWN.")
        case .resetting:
            print("Bluetooth state is RESETTING.")
        case .unsupported:
            print("Bluetooth is UNSUPPORTED on this device.")
        case .unauthorized:
            print("Bluetooth is UNAUTHORIZED.")
        case .poweredOff:
            print("Bluetooth is POWERED OFF.")
            DispatchQueue.main.async {
                self.errorMessage = "Bluetooth is powered off. Please turn it on in Settings."
                self.isConnected = false
                self.isReadyToSend = false
            }
        case .poweredOn:
            print("Bluetooth is POWERED ON.")
            // Optionally, start scanning here if desired.
        @unknown default:
            print("A new Bluetooth state is available.")
        }
    }
    
    /// Called when a peripheral is discovered during scanning.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        // Avoid duplicates
        if !discoveredPeripherals.contains(where: { $0.id == peripheral.identifier }) {
            let discoveredPeripheral = DiscoveredPeripheral(peripheral: peripheral, rssi: RSSI, advertisementData: advertisementData)
            DispatchQueue.main.async {
                self.discoveredPeripherals.append(discoveredPeripheral)
            }
            print("Discovered peripheral: \(discoveredPeripheral.name) RSSI: \(RSSI)")
            // Optionally, print additional advertisement data for debugging
            if let manufacturerData = discoveredPeripheral.manufacturerData {
                print("Manufacturer Data: \(manufacturerData)")
            }
            if !discoveredPeripheral.serviceUUIDs.isEmpty {
                print("Service UUIDs: \(discoveredPeripheral.serviceUUIDs.map { $0.uuidString }.joined(separator: ", "))")
            }
            if !discoveredPeripheral.serviceData.isEmpty {
                let serviceDataStrings = discoveredPeripheral.serviceData.map { "\($0.key.uuidString): \($0.value)" }
                print("Service Data: \(serviceDataStrings.joined(separator: ", "))")
            }
            if let txPower = discoveredPeripheral.txPowerLevel {
                print("TX Power Level: \(txPower)")
            }
        }
    }
    
    /// Called when a connection to a peripheral is successful.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "device").")
        DispatchQueue.main.async {
            self.isConnected = true
            self.isReadyToSend = false
            self.errorMessage = nil
        }
        peripheral.discoverServices(nil) // Discover all services
    }
    
    /// Called when a connection to a peripheral fails.
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "device"): \(error?.localizedDescription ?? "Unknown error").")
        DispatchQueue.main.async {
            self.isConnected = false
            self.isReadyToSend = false
            self.errorMessage = "Failed to connect to \(peripheral.name ?? "device")."
        }
    }
    
    /// Called when a peripheral disconnects.
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral.name ?? "device").")
        DispatchQueue.main.async {
            self.isConnected = false
            self.isReadyToSend = false
            self.errorMessage = "Disconnected from \(peripheral.name ?? "device")."
        }
    }
}

// MARK: - CBPeripheralDelegate

extension BluetoothManager: CBPeripheralDelegate {
    /// Called when services are discovered on the peripheral.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Error discovering services."
            }
            return
        }
        
        guard let services = peripheral.services else {
            print("No services found.")
            DispatchQueue.main.async {
                self.errorMessage = "No services found."
            }
            return
        }
        
        for service in services {
            print("Discovered service: \(service.uuid.uuidString)")
            peripheral.discoverCharacteristics(nil, for: service) // Discover all characteristics for each service
        }
    }
    
    /// Called when characteristics are discovered for a service.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Error discovering characteristics."
            }
            return
        }
        
        guard let characteristics = service.characteristics else {
            print("No characteristics found for service: \(service.uuid.uuidString)")
            DispatchQueue.main.async {
                self.errorMessage = "No characteristics found."
            }
            return
        }
        
        for characteristic in characteristics {
            print("Discovered characteristic: \(characteristic.uuid.uuidString) with properties: \(characteristic.properties)")
            
            // Check if the characteristic has write properties
            if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                writeCharacteristic = characteristic
                print("Found writable characteristic: \(characteristic.uuid.uuidString)")
                DispatchQueue.main.async {
                    self.isReadyToSend = true
                }
                // Optionally, stop searching after finding the first writable characteristic
                break
            }
        }
        
        if writeCharacteristic == nil {
            print("No writable characteristics found.")
            DispatchQueue.main.async {
                self.errorMessage = "No writable characteristics available."
            }
        }
    }
    
    /// Called when the value of a characteristic is updated (e.g., when receiving data).
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error updating value for characteristic \(characteristic.uuid.uuidString): \(error.localizedDescription)")
            return
        }
        
        guard let data = characteristic.value else {
            print("No data received for characteristic \(characteristic.uuid.uuidString).")
            return
        }
        
        receiveMessageFromDevice(data)
    }
    
    /// Handles incoming data from the peripheral.
    /// - Parameter data: The received data.
    func receiveMessageFromDevice(_ data: Data) {
        do {
            if let message = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("Received message: \(message)")
                // Handle the received message as needed
            }
        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
        }
    }
}

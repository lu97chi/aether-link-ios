// DiscoveredPeripheral.swift

import Foundation
import CoreBluetooth

class DiscoveredPeripheral: Identifiable {
    let id: UUID
    let peripheral: CBPeripheral
    let name: String
    let rssi: NSNumber
    let manufacturerData: String?
    let serviceUUIDs: [CBUUID]
    let serviceData: [CBUUID: String]
    let txPowerLevel: Int?
    
    init(peripheral: CBPeripheral, rssi: NSNumber, advertisementData: [String: Any]) {
        self.id = peripheral.identifier
        
        // Extract Local Name
        if let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            self.name = localName
        } else {
            self.name = peripheral.name ?? "Unknown"
        }
        
        self.peripheral = peripheral
        self.rssi = rssi
        
        // Extract Manufacturer Data if available
        if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
            self.manufacturerData = manufacturerData.map { String(format: "%02x", $0) }.joined()
        } else {
            self.manufacturerData = nil
        }
        
        // Extract Service UUIDs if available
        if let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
            self.serviceUUIDs = serviceUUIDs
        } else {
            self.serviceUUIDs = []
        }
        
        // Extract Service Data if available
        if let serviceDataRaw = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data] {
            var serviceDataFormatted: [CBUUID: String] = [:]
            for (uuid, data) in serviceDataRaw {
                serviceDataFormatted[uuid] = data.map { String(format: "%02x", $0) }.joined()
            }
            self.serviceData = serviceDataFormatted
        } else {
            self.serviceData = [:]
        }
        
        // Extract TX Power Level if available
        if let txPower = advertisementData[CBAdvertisementDataTxPowerLevelKey] as? NSNumber {
            self.txPowerLevel = txPower.intValue
        } else {
            self.txPowerLevel = nil
        }
    }
}

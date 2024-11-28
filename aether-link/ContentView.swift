// ContentView.swift

import SwiftUI

struct ContentView: View {
    // Tracks whether the user has seen the onboarding screens
    @State private var showOnboarding: Bool = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    
    // Instantiate BluetoothManager and SocketIOManager
    @StateObject private var bluetoothManager = BluetoothManager()
    @StateObject private var socketIOManager = SocketIOManager()
    
    var body: some View {
        Group {
            MainView()
                .environmentObject(bluetoothManager)    // Pass BluetoothManager to main content
                .environmentObject(socketIOManager)      // Pass SocketIOManager to main content
        }
    }
}

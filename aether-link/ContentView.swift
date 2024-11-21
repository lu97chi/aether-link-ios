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
            if showOnboarding {
                OnboardingContainerView(showOnboarding: $showOnboarding)
                    .onDisappear {
                        // Mark onboarding as seen
                        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                    }
            } else {
                MainView()
                    .environmentObject(bluetoothManager)    // Pass BluetoothManager to main content
                    .environmentObject(socketIOManager)      // Pass SocketIOManager to main content
            }
        }
        .onAppear {
            // Optionally, start the Socket.IO connection here
            // socketIOManager.connect()
            
            // Optionally, start Bluetooth scanning here or handle any initial setup
            // bluetoothManager.startScanning()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(BluetoothManager())
            .environmentObject(SocketIOManager())
    }
}

import SwiftUI

struct MainView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @EnvironmentObject var socketIOManager: SocketIOManager

    var body: some View {
        TabView {
            // Socket.IO Tab
            SocketIOView()
                .tabItem {
                    Label("Socket.IO", systemImage: "network")
                }
                .environmentObject(socketIOManager)

            // Bluetooth Tab
            BluetoothView()
                .tabItem {
                    Label("Bluetooth", systemImage: "dot.radiowaves.left.and.right")
                }
                .environmentObject(bluetoothManager)
        }
        .accentColor(Color("PrimaryBlue")) // Customize the tab highlight color using your palette
    }
}

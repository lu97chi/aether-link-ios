import Foundation
import SocketIO
import Combine
import ActivityKit

/// A class that manages Socket.IO connections.
class SocketIOManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isConnected: Bool = false
    @Published var receivedMessage: String? = nil
    @Published var errorMessage: String? = nil
    @Published var operationType: String? = nil
    @Published var isOperationInProgress: Bool = false
    @Published var status: String = "Unknown"
    
    @Published var statusMessage: String = "Processing..."
    @Published var devicesConnected: Int = 0
    @Published var devicesDetails: [DeviceDetail] = []
    
    // MARK: - DeviceDetail Struct
    struct DeviceDetail: Identifiable, Equatable {
        var id: String // Use src_dir as the unique ID
        var progress: Double
        var fileProgress: Double
        var elapsedTime: Double
        var remainingTime: Double
        var currentFile: String
        var filesProcessed: Int
        var totalFiles: Int
        var srcDir: String
        var destDir: String
        var drive: String
        var fileSize: Int
        var folderSize: Int
        var operationType: String?
        var status: String

        // Initializer to ensure id is always set to srcDir
        init(
            progress: Double,
            fileProgress: Double,
            elapsedTime: Double,
            remainingTime: Double,
            currentFile: String,
            filesProcessed: Int,
            totalFiles: Int,
            srcDir: String,
            destDir: String,
            drive: String,
            fileSize: Int,
            folderSize: Int,
            operationType: String?,
            status: String
        ) {
            self.id = srcDir // Set id to srcDir
            self.progress = progress
            self.fileProgress = fileProgress
            self.elapsedTime = elapsedTime
            self.remainingTime = remainingTime
            self.currentFile = currentFile
            self.filesProcessed = filesProcessed
            self.totalFiles = totalFiles
            self.srcDir = srcDir
            self.destDir = destDir
            self.drive = drive
            self.fileSize = fileSize
            self.folderSize = folderSize
            self.operationType = operationType
            self.status = status
        }
    }
    
    // MARK: - Private Properties
    private var manager: SocketManager
    private var socket: SocketIOClient
    private var cancellables = Set<AnyCancellable>()
    private var activity: Activity<FileTransferActivityAttributes>?
    
    // Replace with your actual server URL
    private let serverURL = URL(string: "http://192.168.0.106:1338")!
    
    // MARK: - Initializer
    init() {
        manager = SocketManager(socketURL: serverURL, config: [
            //.log(true),
            .compress,
            .forceWebsockets(true)
        ])
        socket = manager.defaultSocket
        
        setupSocketEvents()
        connect()
    }
    
    // MARK: - Setup Socket Events
    private func setupSocketEvents() {
        // Handle connection
        socket.on(clientEvent: .connect) { [weak self] _, _ in
            print("✅ Socket connected")
            DispatchQueue.main.async {
                self?.isConnected = true
                self?.errorMessage = nil
                self?.getDevices()
            }
        }
        
        // Handle disconnection
        socket.on(clientEvent: .disconnect) { [weak self] _, _ in
            print("⚠️ Socket disconnected")
            DispatchQueue.main.async {
                self?.isConnected = false
            }
        }
        
        // Handle error
        socket.on(clientEvent: .error) { [weak self] data, _ in
            print("❌ Socket error: \(data)")
            DispatchQueue.main.async {
                self?.errorMessage = "Socket error occurred."
            }
        }
        
        // Handle custom event "message"
        socket.on("message") { [weak self] data, _ in
            if let message = data.first as? String {
                DispatchQueue.main.async {
                    self?.receivedMessage = message
                }
            }
        }
        
        // Handle custom event "status"
        socket.on("status") { [weak self] data, _ in
            guard let self = self else { return }
            
            if let firstData = data.first as? [String: Any],
               let command = firstData["command"] as? String,
               let statusString = firstData["status"] as? String {
                
                DispatchQueue.main.async {
                    self.operationType = command
                    self.status = statusString.lowercased()
                    
                    if command.lowercased() == "detect" {
                        // Handle detect command response
                        if statusString.lowercased() == "done",
                           let mountDevices = firstData["mount_dev"] as? [[String: Any]] {
                            
                            self.devicesConnected = mountDevices.count
                            self.initializeDevicesDetails(with: mountDevices)
                            self.statusMessage = "Devices Detected"
                        } else {
                            // Handle other statuses if necessary
                            self.statusMessage = "Detect Status: \(statusString)"
                        }
                    } else if command.lowercased() == "copy" {
                        // Handle copy command
                        if self.status != "idle" {
                            if let devicesData = firstData["devices_data"] as? [[String: Any]] {
                                for deviceData in devicesData {
                                    guard let srcDir = deviceData["src_dir"] as? String else {
                                        continue // Skip if src_dir is missing
                                    }
    
                                    // Update or add device detail
                                    self.updateDeviceDetail(with: deviceData, srcDir: srcDir)
                                }
                            } else {
                                // If devices_data is not present, assume single device data
                                self.updateDeviceDetail(with: firstData, srcDir: firstData["src_dir"] as? String)
                            }
                        }
                        
                        // Handle overall status
                        self.updateStatus(firstData)
                    } else {
                        // Handle other commands if necessary
                        self.updateStatus(firstData)
                    }
                }
            } else {
                print("⚠️ Invalid status data received: \(data)")
            }
        }
        
        // Listen to all events for debugging
        socket.onAny { event in
            print("🔔 Socket Event: \(event.event) with items: \(event.items ?? [])")
        }
    }
    
    // MARK: - Initialize Devices Details
    private func initializeDevicesDetails(with mountDevices: [[String: Any]]) {
        // Clear existing device details to avoid duplicates
        self.devicesDetails.removeAll()
        
        for device in mountDevices {
            guard let label = device["label"] as? String,
                  let mountpoint = device["mountpoint"] as? String,
                  let name = device["name"] as? String,
                  let size = device["size"] as? String else {
                print("⚠️ Incomplete device data: \(device)")
                continue
            }
            
            // Initialize DeviceDetail with default progress values
            let newDevice = DeviceDetail(
                progress: 0.0,
                fileProgress: 0.0,
                elapsedTime: 0.0,
                remainingTime: 0.0,
                currentFile: "Idle",
                filesProcessed: 0,
                totalFiles: 0,
                srcDir: mountpoint,
                destDir: "",
                drive: "", // Populate if available
                fileSize: 0,
                folderSize: 0,
                operationType: nil,
                status: "idle"
            )
            
            self.devicesDetails.append(newDevice)
        }
        
        print("✅ Initialized devicesDetails with \(self.devicesDetails.count) devices.")
    }
    
    // MARK: - Update Status Method
    private func updateStatus(_ data: [String: Any]) {
        if let statusString = data["status"] as? String {
            switch statusString.lowercased() {
            case "idle":
                self.isOperationInProgress = false
                self.resetToDefaults()
                self.statusMessage = "Idle"
            case "running":
                self.isOperationInProgress = true
                self.statusMessage = "Running"
            case "done":
                self.isOperationInProgress = false
                self.statusMessage = "Completed"
            case "verifying":
                self.statusMessage = "Verifying..."
            case "abort":
                self.isOperationInProgress = false
                self.operationType = "Aborting"
                self.statusMessage = "Operation Aborted"
            case "error":
                self.isOperationInProgress = false
                self.errorMessage = "An error occurred."
                self.statusMessage = "Error"
            default:
                self.statusMessage = "Unknown Status"
            }
        } else {
            self.statusMessage = "Unknown Status"
        }
    }
    
    // MARK: - Reset Method
    func resetToDefaults() {
        self.devicesDetails.removeAll()
        self.statusMessage = "Processing..."
    }
    
    // MARK: - Get Device Detail
    func getDeviceDetail(forSrcDir srcDir: String) -> DeviceDetail? {
        return devicesDetails.first(where: { $0.id == srcDir })
    }
    
    // MARK: - Connect to Socket
    func connect() {
        guard !isConnected else {
            print("🔄 Socket is already connected.")
            return
        }
        socket.connect()
    }
    
    // MARK: - Disconnect from Socket
    func disconnect() {
        guard isConnected else {
            print("❌ Socket is not connected.")
            return
        }
        socket.disconnect()
    }
        
    // MARK: - Send Message Command with Acknowledgment
    func sendMessage(operationType: String, completion: @escaping (Bool) -> Void) {
        guard isConnected else {
            DispatchQueue.main.async {
                self.errorMessage = "Socket is not connected."
            }
            completion(false)
            return
        }
        let payload: [String: Any] = ["command": operationType]
        
        socket.emitWithAck("message", payload).timingOut(after: 5) { data in
            if let ackData = data.first as? String, ackData.lowercased() == "ok" {
                DispatchQueue.main.async {
                    self.operationType = operationType
                }
                completion(true)
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "\(operationType.capitalized) command failed."
                }
                completion(false)
            }
        }
    }
    
    // MARK: - Send Cancel Command
    func sendCancel() {
        guard isConnected else {
            DispatchQueue.main.async {
                self.errorMessage = "Socket is not connected."
            }
            return
        }
        let payload: [String: Any] = ["command": "abort"]
        
        socket.emitWithAck("message", payload).timingOut(after: 5) { data in
            if let ackData = data.first as? String, ackData.lowercased() == "ok" {
                DispatchQueue.main.async {
                    self.operationType = nil
                    self.resetToDefaults()
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Abort command failed."
                }
            }
        }
    }
    
    // MARK: - Get Devices Command
    func getDevices() {
        guard isConnected else {
            DispatchQueue.main.async {
                self.errorMessage = "Socket is not connected."
            }
            return
        }
        let payload: [String: Any] = ["command": "detect"]
        
        socket.emitWithAck("message", payload).timingOut(after: 5) { data in
            if let ackData = data.first as? String, ackData.lowercased() == "ok" {
                // Devices will be updated via the "status" event
                print("✅ 'detect' command acknowledged with 'ok'")
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Get devices command failed."
                }
                print("❌ 'detect' command failed or no acknowledgment")
            }
        }
    }
    
    // MARK: - Helper Methods
    func extractLabels(from mountDevices: [[String: Any]]) -> [String] {
        var labels: [String] = []

        for device in mountDevices {
            if let children = device["children"] as? [[String: Any]] {
                for child in children {
                    if let label = child["label"] as? String, label != "<null>" {
                        labels.append(label)
                    }
                }
            }
        }

        return labels
    }
    
    // MARK: - Update Device Detail Method
    private func updateDeviceDetail(with deviceData: [String: Any], srcDir: String?) {
        guard let srcDir = srcDir else { return }

        // Extract necessary fields with default values
        let progress = deviceData["folder_progress"] as? Double ?? deviceData["progress"] as? Double ?? 0.0
        let fileProgress = deviceData["file_progress"] as? Double ?? 0.0
        let elapsedTime = deviceData["elapsed_time"] as? Double ?? 0.0
        let remainingTime = deviceData["remaining_time"] as? Double ?? 0.0
        let currentFile = deviceData["file"] as? String ?? "Unknown"
        let filesProcessed = deviceData["proc_files"] as? Int ?? 0
        let totalFiles = deviceData["total_files"] as? Int ?? 0
        let destDir = deviceData["dest_dir"] as? String ?? ""
        let drive = deviceData["drive"] as? String ?? ""
        let fileSize = deviceData["file_size"] as? Int ?? 0
        let folderSize = deviceData["folder_size"] as? Int ?? 0
        let operationType = deviceData["command"] as? String
        let status = deviceData["status"] as? String ?? "unknown"

        // Check if the device already exists
        if let index = self.devicesDetails.firstIndex(where: { $0.id == srcDir }) {
            // Update existing device
            self.devicesDetails[index].progress = progress
            self.devicesDetails[index].fileProgress = fileProgress
            self.devicesDetails[index].elapsedTime = elapsedTime
            self.devicesDetails[index].remainingTime = remainingTime
            self.devicesDetails[index].currentFile = currentFile
            self.devicesDetails[index].filesProcessed = filesProcessed
            self.devicesDetails[index].totalFiles = totalFiles
            self.devicesDetails[index].destDir = destDir
            self.devicesDetails[index].drive = drive
            self.devicesDetails[index].fileSize = fileSize
            self.devicesDetails[index].folderSize = folderSize
            self.devicesDetails[index].operationType = operationType
            self.devicesDetails[index].status = status
        } else {
            // Add new device
            let newDevice = DeviceDetail(
                progress: progress,
                fileProgress: fileProgress,
                elapsedTime: elapsedTime,
                remainingTime: remainingTime,
                currentFile: currentFile,
                filesProcessed: filesProcessed,
                totalFiles: totalFiles,
                srcDir: srcDir,
                destDir: destDir,
                drive: drive,
                fileSize: fileSize,
                folderSize: folderSize,
                operationType: operationType,
                status: status
            )
            self.devicesDetails.append(newDevice)
        }
    }
    
    // MARK: - Deinitializer
    deinit {
        socket.disconnect()
    }
}

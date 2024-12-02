import Foundation
import SocketIO
import Combine
import ActivityKit

enum StatusTypes {
    case idle
    case running
    case done
    case error
}

/// A class that manages Socket.IO connections.
class SocketIOManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isConnected: Bool = false
    @Published var receivedMessage: String? = nil
    @Published var errorMessage: String? = nil
    @Published var operationType: String? = nil
    @Published var isOperationInProgress: Bool = false
    
    @Published var progress: Double = 0.0 // Overall progress (folder_progress)
    @Published var currentFile: String = "Unknown"
    @Published var filesProcessed: Int = 0
    @Published var totalFiles: Int = 0
    @Published var fileProgress: Double = 0.0 // Per-file progress (file_progress)
    @Published var elapsedTime: Double = 0.0
    @Published var remainingTime: Double = 0.0
    @Published var statusMessage: String = "Processing..."
    
    @Published var srcDir: String = ""
    @Published var destDir: String = ""
    @Published var drive: String = ""
    @Published var fileSize: Int = 0
    @Published var folderSize: Int = 0
    
    // MARK: - Private Properties
    private var manager: SocketManager
    private var socket: SocketIOClient
    private var cancellables = Set<AnyCancellable>()
    private var activity: Activity<FileTransferActivityAttributes>?
    
    // Replace with your actual server URL
    private let serverURL = URL(string: "http://192.168.1.109:1338")!
    
    // MARK: - Initializer
    init() {
        manager = SocketManager(socketURL: serverURL, config: [
            .log(true),
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
            print("Socket connected")
            DispatchQueue.main.async {
                self?.isConnected = true
                self?.errorMessage = nil
            }
        }
        
        // Handle disconnection
        socket.on(clientEvent: .disconnect) { [weak self] _, _ in
            print("Socket disconnected")
            DispatchQueue.main.async {
                self?.isConnected = false
            }
        }
        
        // Handle error
        socket.on(clientEvent: .error) { [weak self] data, _ in
            print("Socket error: \(data)")
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
            
            if let firstData = data.first as? [String: Any] {
                DispatchQueue.main.async {
                    self.progress = firstData["folder_progress"] as? Double ?? 0.0
                    self.fileProgress = firstData["file_progress"] as? Double ?? 0.0
                    self.elapsedTime = firstData["elapsed_time"] as? Double ?? 0.0
                    self.remainingTime = firstData["remaining_time"] as? Double ?? 0.0
                    self.currentFile = firstData["file"] as? String ?? "Unknown"
                    self.filesProcessed = firstData["proc_files"] as? Int ?? 0
                    self.totalFiles = firstData["total_files"] as? Int ?? 0
                    self.srcDir = firstData["src_dir"] as? String ?? ""
                    self.destDir = firstData["dest_dir"] as? String ?? ""
                    self.drive = firstData["drive"] as? String ?? ""
                    self.fileSize = firstData["file_size"] as? Int ?? 0
                    self.folderSize = firstData["folder_size"] as? Int ?? 0
                    self.operationType = firstData["commad"] as? String ?? "unknown"

                    if let statusString = firstData["status"] as? String {
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
            } else {
                print("Invalid status data received: \(data)")
            }
        }
        
        // Listen to all events for debugging
        socket.onAny { event in
            print("Socket Event: \(event.event) with items: \(event.items)")
        }
    }
    
    func resetToDefaults() {
        self.progress = 0
        self.fileProgress = 0.0
        self.currentFile = "Unknown"
        self.filesProcessed = 0
        self.totalFiles = 0
        self.elapsedTime = 0.0
        self.remainingTime = 0.0
        self.statusMessage = "Processing..."
        self.srcDir = ""
        self.destDir = ""
        self.drive = ""
        self.fileSize = 0
        self.folderSize = 0
    }
    
    // MARK: - Connect to Socket
    func connect() {
        guard !isConnected else {
            print("Socket is already connected.")
            return
        }
        socket.connect()
    }
    
    // MARK: - Disconnect from Socket
    func disconnect() {
        guard isConnected else {
            print("Socket is not connected.")
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
        let payload: [String: Any] = ["command": operationType, "timestamp": Date().timeIntervalSince1970]
        
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
        let payload: [String: Any] = ["command": "cancel", "timestamp": Date().timeIntervalSince1970]
        
        socket.emitWithAck("abort", payload).timingOut(after: 5) { data in
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
    
    // MARK: - Deinitializer
    deinit {
        socket.disconnect()
    }
}

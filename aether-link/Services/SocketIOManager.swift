// SocketIOManager.swift
// Prod http://192.168.100.100:1337
// Dev http://192.168.1.109:3000

import Foundation
import SocketIO
import Combine
import ActivityKit


/// A class that manages Socket.IO connections.
class SocketIOManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isConnected: Bool = false
    @Published var receivedMessage: String? = nil
    @Published var progress: Int = 0
    @Published var errorMessage: String? = nil
    @Published var operationType: String? = nil
    @Published var isOperationInProgress: Bool = false
    @Published var totalFiles: Int = 12
    @Published var currentFileName: String = "Test"
    @Published var filesProcessed: Int = 4
    @Published var startTime: Date = Date()
    
    
    
    // MARK: - Private Properties
    private var manager: SocketManager
    private var socket: SocketIOClient
    private var cancellables = Set<AnyCancellable>()
    private var activity: Activity<FileTransferActivityAttributes>?
    
    // Replace with your actual server URL
    private let serverURL = URL(string: "http://192.168.100.100:1337")!
    
    // MARK: - Initializer
    init() {
        // Enable detailed logging and force WebSockets if necessary
        manager = SocketManager(socketURL: serverURL, config: [
            .log(true),
            .compress,
            .forceWebsockets(true)
            // Add more configurations if needed
        ])
        socket = manager.defaultSocket
        
        setupSocketEvents()
        connect() // Auto-connect upon initialization
    }
    
    // MARK: - Setup Socket Events
    private func setupSocketEvents() {
        // Handle connection
        socket.on(clientEvent: .connect) { [weak self] data, ack in
            print("Socket connected")
            DispatchQueue.main.async {
                self?.isConnected = true
                self?.errorMessage = nil
            }
        }
        
        // Handle disconnection
        socket.on(clientEvent: .disconnect) { [weak self] data, ack in
            print("Socket disconnected")
            DispatchQueue.main.async {
                self?.isConnected = false
            }
        }
        
        // Handle error
        socket.on(clientEvent: .error) { [weak self] data, ack in
            print("Socket error: \(data)")
            DispatchQueue.main.async {
                self?.errorMessage = "Socket error occurred."
            }
        }
        
        // Handle custom event "message"
        socket.on("message") { [weak self] data, ack in
            if let message = data.first as? String {
                self?.receivedMessage = message
            }
        }
        
        // Handle custom event "message"
        socket.on("status") { [weak self] data, ack in
            if let firstData = data.first as? [String: Any], // Cast `data.first` to a dictionary
               let progress = firstData["progress"] as? Int { // Safely extract `progress`
                DispatchQueue.main.async {
                    self?.progress = progress
                }
            }
        }
        
        // Handle custom event "notification"
        socket.on("confirm") { [weak self] data, ack in
            if let firstData = data.first as? [String: Any], // Cast `data.first` to a dictionary
               let isCompleted = firstData["completed"] as? Bool { // Safely extract `notification`
                if isCompleted == true {
                    DispatchQueue.main.async {
                        self?.isOperationInProgress = false;
                        self?.progress = 0;
                        self?.operationType = nil;
                    }
                }
                
            }
        }

        
        // Listen to all events for debugging
        socket.onAny { event in
            print("Socket Event: \(event.event) with items: \(event.items)")
        }
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
    func sendMessage(message:String, completion: @escaping (Bool) -> Void) {
        guard isConnected else {
            print("Cannot send copy. Socket is not connected.")
            DispatchQueue.main.async {
                self.errorMessage = "Socket is not connected."
            }
            completion(false)
            return
        }
        // Example payload; adjust based on server requirements
        let payload: [String: Any] = ["command": message, "timestamp": Date().timeIntervalSince1970]
        
        
        socket.emitWithAck("message", payload).timingOut(after: 5) {
            data in
            if let ackData = data.first as? String, ackData == "ok" {
                print("Copy command acknowledged by server.")
                DispatchQueue.main.async {
                    self.operationType = message
                }
                completion(true)
            } else {
                print("Copy command failed or was not acknowledged.")
                DispatchQueue.main.async {
                    self.errorMessage = "Copy command failed."
                }
                completion(false)
            }
        }
    }
    
    // MARK: - Send Cancel Command with Acknowledgment
    func sendCancel() {
        guard isConnected else {
            print("Cannot Abort. Socket is not connected.")
            DispatchQueue.main.async {
                self.errorMessage = "Socket is not connected."
            }
            return
        }
        // Example payload; adjust based on server requirements
        let payload: [String: Any] = ["command": "cancel", "timestamp": Date().timeIntervalSince1970]
        
        
        socket.emitWithAck("abort", payload).timingOut(after: 5) {
            data in
            if let ackData = data.first as? String, ackData == "ok" {
                print("Abort command aknowledged by server.")
                self.operationType = nil
                self.progress = 0
                self.isOperationInProgress = false
            } else {
                print("Abort failed or was not acknowledged.")
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


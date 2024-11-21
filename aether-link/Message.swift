// Message.swift

import Foundation
import CryptoKit

struct Message: Codable {
    let date: String
    let action: String
    let signature: String
    // Add other fields as needed
    
    init(action: String) {
        self.date = ISO8601DateFormatter().string(from: Date())
        self.action = action
        self.signature = UUID().uuidString // Or use a different hash function if needed
    }
    
    // Optional: Encrypted Message Example
    /*
    func encryptedMessage() throws -> Data {
        let messageData = try JSONEncoder().encode(self)
        let key = SymmetricKey(size: .bits256)
        let sealedBox = try AES.GCM.seal(messageData, using: key)
        return sealedBox.combined!
    }
    */
}

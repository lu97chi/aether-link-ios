//
//  DeviceTransferInfo.swift
//  ÆtherL
//
//  Created by Luis Roberto Hernandez Robles on 05/12/24.
//

import Foundation

/// Holds transfer-related data for a single device
struct DeviceTransferInfo: Equatable {
    var status: String
    var progress: Double
    var currentFile: String
    var filesProcessed: Int
    var totalFiles: Int
    var fileProgress: Double
    var elapsedTime: Double
    var remainingTime: Double
    var srcDir: String
    var destDir: String
    var drive: String
    var fileSize: Int
    var folderSize: Int
    var statusMessage: String

    // Default initializer with default values
    init(status: String = "Unknown",
         progress: Double = 0.0,
         currentFile: String = "Unknown",
         filesProcessed: Int = 0,
         totalFiles: Int = 0,
         fileProgress: Double = 0.0,
         elapsedTime: Double = 0.0,
         remainingTime: Double = 0.0,
         srcDir: String = "",
         destDir: String = "",
         drive: String = "",
         fileSize: Int = 0,
         folderSize: Int = 0,
         statusMessage: String = "Processing...") {
        self.status = status
        self.progress = progress
        self.currentFile = currentFile
        self.filesProcessed = filesProcessed
        self.totalFiles = totalFiles
        self.fileProgress = fileProgress
        self.elapsedTime = elapsedTime
        self.remainingTime = remainingTime
        self.srcDir = srcDir
        self.destDir = destDir
        self.drive = drive
        self.fileSize = fileSize
        self.folderSize = folderSize
        self.statusMessage = statusMessage
    }

    static func == (lhs: DeviceTransferInfo, rhs: DeviceTransferInfo) -> Bool {
        return lhs.status == rhs.status &&
               lhs.progress == rhs.progress &&
               lhs.currentFile == rhs.currentFile &&
               lhs.filesProcessed == rhs.filesProcessed &&
               lhs.totalFiles == rhs.totalFiles &&
               lhs.fileProgress == rhs.fileProgress &&
               lhs.elapsedTime == rhs.elapsedTime &&
               lhs.remainingTime == rhs.remainingTime &&
               lhs.srcDir == rhs.srcDir &&
               lhs.destDir == rhs.destDir &&
               lhs.drive == rhs.drive &&
               lhs.fileSize == rhs.fileSize &&
               lhs.folderSize == rhs.folderSize &&
               lhs.statusMessage == rhs.statusMessage
    }
}

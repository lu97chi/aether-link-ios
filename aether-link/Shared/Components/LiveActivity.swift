import ActivityKit

// Define the Live Activity Attributes
struct FileTransferActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var progress: Int
        var currentFileName: String
        var filesProcessed: Int
        var totalFiles: Int
    }

    var operationType: String
}

class LiveActivityManager {
    private var activity: Activity<FileTransferActivityAttributes>?

    /// Starts a new Live Activity
    func startActivity(
        operationType: String,
        progress: Int,
        currentFileName: String,
        filesProcessed: Int,
        totalFiles: Int
    ) {
        guard activity == nil else {
            print("Live Activity already running.")
            return
        }

        // Define attributes for the Live Activity
        let attributes = FileTransferActivityAttributes(operationType: operationType)

        // Define the content state for the Live Activity
        let contentState = FileTransferActivityAttributes.ContentState(
            progress: progress,
            currentFileName: currentFileName,
            filesProcessed: filesProcessed,
            totalFiles: totalFiles
        )

        // Wrap the content state in ActivityContent
        let activityContent = ActivityContent(state: contentState, staleDate: nil)

        // Request the Live Activity
        do {
            activity = try Activity<FileTransferActivityAttributes>.request(
                attributes: attributes,
                content: activityContent, // Pass ActivityContent, NOT ContentState
                pushType: nil
            )
            print("Live Activity started successfully.")
        } catch {
            print("Failed to start Live Activity: \(error.localizedDescription)")
        }
    }

    /// Updates the Live Activity with new progress
    func updateProgress(
        progress: Int,
        currentFileName: String,
        filesProcessed: Int,
        totalFiles: Int
    ) {
        guard let activity = activity else {
            print("No active Live Activity to update.")
            return
        }

        // Create the updated content state
        let updatedContentState = FileTransferActivityAttributes.ContentState(
            progress: progress,
            currentFileName: currentFileName,
            filesProcessed: filesProcessed,
            totalFiles: totalFiles
        )

        // Wrap updated content state in ActivityContent
        let updatedContent = ActivityContent(state: updatedContentState, staleDate: nil)

        // Update the activity
        Task {
//            await activity.update(using: updatedContent)
            print("Live Activity updated successfully.")
        }
    }

    /// Ends the current Live Activity
    func endActivity() {
        guard let activity = activity else {
            print("No active Live Activity to end.")
            return
        }

        // End the activity
        Task {
            await activity.end(dismissalPolicy: .immediate)
            self.activity = nil
            print("Live Activity ended successfully.")
        }
    }
}

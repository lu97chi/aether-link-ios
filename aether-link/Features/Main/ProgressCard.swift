// ProgressCard.swift

import SwiftUI

// MARK: - CircularProgressBar View
struct CircularProgressBar: View {
    var lineWidth: CGFloat = 10
    var gradientColors: [Color] = [Color.progressGradientStart, Color.progressGradientEnd]
    @Binding var progress: Int
    var abortOperation: () -> Void
    
    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(
                    Color.gray.opacity(0.3),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: 80, height: 80)
            
            // Progress Circle
            Circle()
                .trim(from: 0.0, to: CGFloat(min(Double(progress), 1.0)))
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(Angle(degrees: -90))
                .animation(.easeInOut(duration: 0.5), value: progress)
                .frame(width: 80, height: 80)
            
            // Percentage Text
            Text("\(Int(progress))%")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - ProgressCard View
struct ProgressCard: View {
    @Binding var progress: Int
    @Binding var operationType: String?
    var abortOperation: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with Icon and Operation Type
            HStack(spacing: 15) {
                Image(systemName: operationType == nil ? "gearshape.fill" : operationType == "Copy" ? "doc.on.doc.fill" : "trash.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(operationType == nil ? .gray : operationType == "Copy" ? .blue : .red)
                    .shadow(radius: 2)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(operationType ?? "Operation")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("in Progress")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            // Circular Progress Indicator
            CircularProgressBar(progress: $progress, abortOperation: abortOperation)
                .frame(width: 100, height: 100)
                .padding(.top, 10)
                .accessibilityElement(children: .ignore)
                .accessibility(label: Text("\(Int(progress)) percent completed"))
            
            // Progress Description
            Text("\(Int(progress))% Completed")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 5)
            
            // Optional: Cancel Button (if applicable)
            if progress < 100 {
                Button(action: {
                    // Define cancel action
                    cancelOperation(abortOperation: abortOperation)
                }) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .font(.headline)
                        Text("Cancel")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
                    .shadow(color: Color.red.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                .accessibility(label: Text("Cancel Operation"))
                .transition(.opacity)
                .animation(.easeInOut, value: progress)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.cardBackgroundLight, Color.cardBackgroundDark]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .animation(.easeInOut, value: progress)
        .accessibilityElement(children: .combine)
    }
    
    // MARK: - Action Methods
    private func cancelOperation(abortOperation: @escaping () -> Void) {
        // Implement cancellation logic here
        print("Operation cancelled.")
        abortOperation()
        // Optionally, emit a cancel event to the server or reset progress
    }
}

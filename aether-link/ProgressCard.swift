// ProgressCard.swift

import SwiftUI

struct ProgressCard: View {
    @Binding var progress: Float
    @Binding var operationType: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                Text("\(operationType?.capitalized ?? "Operation") in Progress")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(height: 10)
                .cornerRadius(5)
                .animation(.linear, value: progress)
            
            Text("\(Int(progress * 100))% Completed")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct ProgressCard_Previews: PreviewProvider {
    static var previews: some View {
        ProgressCard(progress: .constant(0.5), operationType: .constant("Copy"))
            .previewLayout(.sizeThatFits)
    }
}

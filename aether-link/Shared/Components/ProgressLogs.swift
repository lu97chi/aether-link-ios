import SwiftUI

struct ProgressLogs: View {
    var messages: [String]
    var currentMessageIndex: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Progress Details")
                .font(.headline)
                .foregroundColor(Color("Text"))

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<messages.count, id: \.self) { index in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: index <= currentMessageIndex ? "checkmark.circle.fill" : "circle")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundColor(index <= currentMessageIndex ? Color("PrimaryBlue") : Color("Outline"))
                                .padding(.top, 2)

                            Text(messages[index])
                                .font(.subheadline)
                                .foregroundColor(index <= currentMessageIndex ? Color("Text") : Color("SubtleText"))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .transition(.opacity)
                    }
                }
                .padding(.vertical, 5)
            }
            .frame(maxHeight: 150)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("Background"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("Outline"), lineWidth: 1)
            )
        }
    }
}

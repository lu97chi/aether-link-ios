import SwiftUI

struct ProgressLogs: View {
    var messages: [String]
    var currentMessageIndex: Int

    @State private var isExpanded: Bool = true // Start expanded by default

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with expand/collapse button
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "list.bullet")
                        .foregroundColor(Color("PrimaryBlue"))
                    Text("Progress Details")
                        .font(.headline)
                        .foregroundColor(Color("Text"))
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(Color("SubtleText"))
                }
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<messages.count, id: \.self) { index in
                        HStack(alignment: .center, spacing: 8) {
                            Image(systemName: index <= currentMessageIndex ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(index <= currentMessageIndex ? Color("PrimaryBlue") : Color("Outline"))
                                .frame(width: 20, height: 20)

                            Text(messages[index])
                                .font(.subheadline)
                                .foregroundColor(index <= currentMessageIndex ? Color("Text") : Color("SubtleText"))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.leading, 2)
                .transition(.opacity)
            }
        }
        .padding()
    }
}

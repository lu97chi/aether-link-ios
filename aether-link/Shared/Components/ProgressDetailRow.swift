// ProgressDetailRow.swift

import SwiftUI

struct ProgressDetailRow: View {
    var label: String
    var value: String
    var systemImage: String

    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(Color("PrimaryBlue"))
                .frame(width: 20)
            Text(label)
                .font(.body)
                .foregroundColor(Color("SubtleText"))
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(Color("Text"))
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }
}

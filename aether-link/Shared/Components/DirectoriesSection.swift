// DirectoriesSection.swift

import SwiftUI

struct DirectoriesSection: View {
    var srcDir: String
    var destDir: String

    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "folder")
                        .foregroundColor(Color("PrimaryBlue"))
                    Text("Directories")
                        .font(.headline)
                        .foregroundColor(Color("Text"))
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(Color("SubtleText"))
                }
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: "arrow.backward")
                            .foregroundColor(Color("PrimaryBlue"))
                        Text("Source:")
                            .font(.subheadline)
                            .foregroundColor(Color("SubtleText"))
                        Spacer()
                        Text(srcDir)
                            .font(.subheadline)
                            .foregroundColor(Color("Text"))
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }

                    HStack {
                        Image(systemName: "arrow.forward")
                            .foregroundColor(Color("PrimaryBlue"))
                        Text("Destination:")
                            .font(.subheadline)
                            .foregroundColor(Color("SubtleText"))
                        Spacer()
                        Text(destDir)
                            .font(.subheadline)
                            .foregroundColor(Color("Text"))
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
                .padding(.leading, 10)
                .transition(.opacity)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color("Background"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color("Outline"), lineWidth: 1)
        )
    }
}

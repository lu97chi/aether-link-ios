//
//  HeaderView.swift
//  ÆtherL
//
//  Created by Luis Roberto Hernandez Robles on 06/12/24.
//

import SwiftUI

struct HeaderView: View {
    var operationType: String?
    var isOperationInProgress: Bool

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: operationIconName())
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .foregroundColor(operationIconColor())
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(operationType?.capitalized ?? "Unknown Operation")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("Text"))

                Text(isOperationInProgress ? "In Progress" : "Completed")
                    .font(.subheadline)
                    .foregroundColor(Color("SubtleText"))
            }
            Spacer()
        }
    }

    private func operationIconName() -> String {
        if let operationType = operationType?.lowercased() {
            switch operationType {
            case "copy":
                return "doc.on.doc.fill"
            case "erase":
                return "trash.fill"
            default:
                return "gearshape.fill"
            }
        }
        return "gearshape.fill"
    }

    private func operationIconColor() -> Color {
        if let operationType = operationType?.lowercased() {
            switch operationType {
            case "copy":
                return Color("HighlightCyan")
            case "erase":
                return Color.red
            default:
                return Color("SubtleText")
            }
        }
        return Color("SubtleText")
    }
}

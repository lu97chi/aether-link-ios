//
//  ActionButton.swift
//  aether-link
//
//  Created by Luis Roberto Hernandez Robles on 18/11/24.
//

import SwiftUI

struct ActionButton: View {
    let title: String
    let iconName: String
    let backgroundColor: Color
    var isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            if !isDisabled {
                action()
            }
        }) {
            VStack {
                Image(systemName: iconName)
                    .font(.title)
                    .padding()
                    .background(
                        backgroundColor.opacity(isDisabled ? 0.1 : 0.2)
                    )
                    .clipShape(Circle())
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(width: 80)
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .disabled(isDisabled)
    }
}


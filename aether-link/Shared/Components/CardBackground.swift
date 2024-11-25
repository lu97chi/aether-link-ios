//
//  CardBackground.swift
//  aether-link
//
//  Created by Luis Roberto Hernandez Robles on 18/11/24.
//

import SwiftUI

struct CardBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

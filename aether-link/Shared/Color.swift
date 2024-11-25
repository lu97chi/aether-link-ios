//
//  Color.swift
//  aether-link
//
//  Created by Luis Roberto Hernandez Robles on 22/11/24.
//

// MARK: - Color Extensions for Custom Gradients
import SwiftUI

// MARK: - Color Extensions for Custom Gradients and Themes
extension Color {
    // MARK: Button Colors
    static let buttonBlueStart = Color.blue.opacity(0.8)
    static let buttonBlueEnd = Color.blue
    static let buttonRedStart = Color.red.opacity(0.8)
    static let buttonRedEnd = Color.red
    static let buttonGrayStart = Color.gray.opacity(0.6)
    static let buttonGrayEnd = Color.gray.opacity(0.4)
    
    // MARK: Card Background Colors
    static let cardBackgroundLight = Color(.systemBackground)
    static let cardBackgroundDark = Color(.systemGray6)
    
    // MARK: Connection Status Colors
    static let connectedGradientStart = Color.green.opacity(0.7)
    static let connectedGradientEnd = Color.green.opacity(0.3)
    static let disconnectedGradientStart = Color.red.opacity(0.7)
    static let disconnectedGradientEnd = Color.red.opacity(0.3)
    
    // MARK: Progress Indicator Colors
    static let progressGradientStart = Color.purple.opacity(0.7)
    static let progressGradientEnd = Color.pink.opacity(0.7)
}

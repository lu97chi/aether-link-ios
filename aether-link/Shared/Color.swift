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
    
    // MARK: Color
    var components: (red: Double, green: Double, blue: Double, opacity: Double) {
        #if canImport(UIKit)
        typealias NativeColor = UIColor
        #elseif canImport(AppKit)
        typealias NativeColor = NSColor
        #endif

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var opacity: CGFloat = 0

        // Use platform-specific conversion
        let nativeColor = NativeColor(self)
        
        // Extract components
        if nativeColor.getRed(&red, green: &green, blue: &blue, alpha: &opacity) {
            return (Double(red), Double(green), Double(blue), Double(opacity))
        }

        // Fallback for unsupported colors
        return (0, 0, 0, 0)
    }

    
    // MARK: - Custom Gradient
    static func dynamicGradient(for progress: Int) -> [Color] {
        let percentage = Double(progress) / 100.0
        let startColor = Color.red
        let endColor = Color.green
        let currentColor = Color(
            red: startColor.components.red + percentage * (endColor.components.red - startColor.components.red),
            green: startColor.components.green + percentage * (endColor.components.green - startColor.components.green),
            blue: startColor.components.blue + percentage * (endColor.components.blue - startColor.components.blue)
        )
        return [currentColor.opacity(0.8), currentColor]
    }
    

}

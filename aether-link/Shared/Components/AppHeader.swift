import SwiftUI

// MARK: - AppHeader View
struct AppHeader: View {
    var body: some View {
        ZStack {
            // Background Color
            Color("Surface")
                .edgesIgnoringSafeArea(.top)
                .frame(height: 40) // Reduced height for a compact look

            // Content
            HStack(spacing: 10) {
                // App Icon
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color("PrimaryBlue"))

                // App Name
                Text("ÆtherL")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color("Text"))
            }
            .padding(.top, 150) // Adjusted padding to move below the dynamic island
        }
    }
}

//
//  InfoView.swift
//  aether-link
//
//  Created by Luis Roberto Hernandez Robles on 18/11/24.
//

import SwiftUI

struct InfoView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("About Aetherlink")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("""
                Aetherlink is an app designed to connect with external devices seamlessly. It allows you to manage your device connections, send commands, and monitor progress all in one place.
                """)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()

                Spacer()
            }
            .padding()
            .navigationBarTitle("Info", displayMode: .inline)
        }
    }
}

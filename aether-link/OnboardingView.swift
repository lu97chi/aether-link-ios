// OnboardingView.swift

import SwiftUI

struct OnboardingView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .padding()
                .shadow(radius: 10)
                .cornerRadius(15)
            
            VStack(alignment: .center, spacing: 10) {
                Text(page.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        let samplePage = OnboardingPage(
            imageName: "onboarding1",
            title: "Connect Seamlessly",
            description: "Easily connect to your Raspberry Pi and manage your devices with just a few taps."
        )
        OnboardingView(page: samplePage)
    }
}

// OnboardingContainerView.swift

import SwiftUI

struct OnboardingContainerView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    @EnvironmentObject var bluetoothManager: BluetoothManager
    
    let onboardingPages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "onboarding1",
            title: "Connect Seamlessly",
            description: "Easily connect to your Raspberry Pi and manage your devices with just a few taps."
        ),
        OnboardingPage(
            imageName: "onboarding2",
            title: "Manage Devices",
            description: "Monitor and control your devices efficiently from a centralized interface."
        ),
        OnboardingPage(
            imageName: "onboarding3",
            title: "Secure Communication",
            description: "Ensure your data is safe with encrypted and authenticated connections."
        )
    ]
    
    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                ForEach(0..<onboardingPages.count) { index in
                    OnboardingView(page: onboardingPages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            VStack {
                Spacer()
                
                // Page Indicator Dots
                HStack(spacing: 8) {
                    ForEach(0..<onboardingPages.count) { index in
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(currentPage == index ? .blue : .gray.opacity(0.5))
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .padding(.bottom, 100)
                
                // Next/Back Buttons
                HStack {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            HStack {
                                Image(systemName: "chevron.left.circle.fill")
                                Text("Back")
                            }
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            if currentPage < onboardingPages.count - 1 {
                                currentPage += 1
                            } else {
                                // Dismiss the onboarding by setting showOnboarding to false
                                showOnboarding = false
                            }
                        }
                    }) {
                        HStack {
                            Text(currentPage < onboardingPages.count - 1 ? "Next" : "Get Started")
                            Image(systemName: "chevron.right.circle.fill")
                        }
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingContainerView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingContainerView(showOnboarding: .constant(true))
            .environmentObject(BluetoothManager())
    }
}

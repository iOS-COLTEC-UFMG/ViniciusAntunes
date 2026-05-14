//
//  testeApp.swift
//  trabalho-final
//
//  Created by coltec on 23/04/26.
//

import SwiftUI

@main
struct testeApp: App {
    // Controla qual tela está ativa no momento
    @State private var currentScreen: AppScreen = .splash

    var body: some Scene {
        WindowGroup {
            switch currentScreen {
            case .splash:
                SplashView {
                    // Ao terminar a splash, vai para onboarding 1
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentScreen = .onboardingPurpose
                    }
                }
            case .onboardingPurpose:
                OnboardingPurposeView {
                    // Ao clicar na seta, vai para onboarding 2 (permissão microfone)
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentScreen = .onboardingMicrophone
                    }
                }
            case .onboardingMicrophone:
                OnboardingMicrophoneView {
                    // Após permissão (ou negação tratada), vai para Home
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentScreen = .home
                    }
                }
            case .home:
                HomeView()
            }
        }
    }
}

// Enum que representa cada tela possível do app
enum AppScreen {
    case splash
    case onboardingPurpose
    case onboardingMicrophone
    case home
}

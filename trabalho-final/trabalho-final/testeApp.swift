//
//  testeApp.swift
//  trabalho-final
//
//  Created by coltec on 23/04/26.
//

import SwiftUI

@main
struct testeApp: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView()
                    .onAppear {
                        // Após 2,5 segundos, troca para a tela principal
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showSplash = false
                            }
                        }
                    }
            } else {
                MainTabView()  // Nossa futura tela principal (placeholder)
            }
        }
    }
}

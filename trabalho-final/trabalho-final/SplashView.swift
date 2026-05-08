//
//  SplashView.swift
//  trabalho-final
//
//  Created by coltec on 07/05/26.
//

import SwiftUI

struct SplashView: View {
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            // Fundo
            Color(red: 0.18, green: 0.24, blue: 0.38)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // Círculo pulsante
                PulsingCircle(isPulsing: $isPulsing)

                // Nome do app
                Text("SensorySafe")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)  // Agora visível sobre fundo escuro
            }
        }
        .onAppear {
            isPulsing = true
        }
    }
}

// Componente separado para o círculo pulsante
struct PulsingCircle: View {
    @Binding var isPulsing: Bool

    var body: some View {
        ZStack {
            // Círculo principal
            Circle()
                .fill(Color.purple)
                .frame(width: 100, height: 100)

            // Ondas pulsantes
            ForEach(0..<3) { i in
                Circle()
                    .stroke(Color.purple.opacity(0.3), lineWidth: 2)
                    .frame(
                        width: isPulsing ? 150 + CGFloat(i * 20) : 100,
                        height: isPulsing ? 150 + CGFloat(i * 20) : 100
                    )
                    .scaleEffect(isPulsing ? 1.2 : 1.0)
                    .opacity(isPulsing ? 0 : 0.5)
                    .animation(
                        .easeOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                            .delay(Double(i) * 0.3),
                        value: isPulsing
                    )
            }
        }
    }
}

//
//  OnboardingPurposeView.swift
//  trabalho-final
//
//  Created by coltec on 14/05/26.
//

import SwiftUI

struct OnboardingPurposeView: View {
    // Callback para avançar à próxima tela
    let onNext: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Fundo (pode ser gradiente ou cor sólida)
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.18, green: 0.24, blue: 0.38),
                                            Color(red: 0.1, green: 0.15, blue: 0.25)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Spacer()

                // Título destacado
                Text("30 dB SPL")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)

                // Subtítulo
                Text("Seu porto seguro sensorial")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))

                // Texto explicativo
                Text("Entendemos que o mundo pode ser barulhento demais. O SensorySafe traduz o som ao seu redor em informações claras para ajudar você a decidir onde e como permanecer.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                // Botão de próximo (seta para direita, canto inferior direito)
                HStack {
                    Spacer()
                    Button(action: onNext) {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                    }
                    .padding(.trailing, 30)
                    .padding(.bottom, 40)
                }
            }
            .padding(.horizontal, 30)
        }
    }
}

// Preview
#Preview {
    OnboardingPurposeView(onNext: {})
}

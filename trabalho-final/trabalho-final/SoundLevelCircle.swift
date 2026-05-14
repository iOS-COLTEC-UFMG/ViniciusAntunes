//
//  SoundLevelCircle.swift
//  trabalho-final
//
//  Created by coltec on 14/05/26.
//

import SwiftUI

struct SoundLevelCircle: View {
    let state: SoundLevelState
    let decibels: Double

    // Controla a animação de pulsação (dispara onAppear)
    @State private var isPulsing = false

    // Define a cor com base no estado
    private var mainColor: Color {
        switch state {
        case .comfortable: return .green
        case .attention: return .yellow
        case .risk: return .red
        case .disabled: return .gray
        }
    }

    // Intensidade da pulsação: quanto maior o nível, maior a expansão das ondas
    private var pulseScale: CGFloat {
        switch state {
        case .comfortable: return 1.15
        case .attention: return 1.25
        case .risk: return 1.4
        case .disabled: return 1.0
        }
    }

    // Tamanho base do círculo
    private let baseSize: CGFloat = 120

    var body: some View {
        ZStack {
            // Círculo principal (preenchido)
            Circle()
                .fill(mainColor)
                .frame(width: baseSize, height: baseSize)
                .shadow(color: mainColor.opacity(0.5), radius: 10)

            // Ondas pulsantes (2 ondas para suavizar)
            ForEach(0..<2) { i in
                Circle()
                    .stroke(mainColor.opacity(0.4), lineWidth: 2)
                    .frame(
                        width: isPulsing ? baseSize * pulseScale + CGFloat(i * 20) : baseSize,
                        height: isPulsing ? baseSize * pulseScale + CGFloat(i * 20) : baseSize
                    )
                    .scaleEffect(isPulsing ? pulseScale : 1.0)
                    .opacity(isPulsing ? 0 : 0.6)
                    .animation(
                        .easeOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                            .delay(Double(i) * 0.3),
                        value: isPulsing
                    )
            }
        }
        .onAppear {
            isPulsing = true
        }
        .onChange(of: state) {
            // Reinicia a animação para garantir continuidade ao mudar de estado
            isPulsing = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPulsing = true
            }
        }
    }
}

// Preview para teste
#Preview {
    VStack(spacing: 30) {
        SoundLevelCircle(state: .comfortable, decibels: 30)
        SoundLevelCircle(state: .attention, decibels: 65)
        SoundLevelCircle(state: .risk, decibels: 85)
    }
    .preferredColorScheme(.dark)
}

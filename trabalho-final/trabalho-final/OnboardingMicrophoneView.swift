//
//  OnboardingMicrophoneView.swift
//  trabalho-final
//
//  Created by coltec on 14/05/26.
//

import SwiftUI
import AVFoundation

struct OnboardingMicrophoneView: View {
    // Callback para quando o usuário avançar (após permissão ou negação)
    let onFinish: () -> Void

    // Controla exibição de alerta em caso de negação
    @State private var showDeniedAlert = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Fundo escuro suave
            Color(red: 0.18, green: 0.24, blue: 0.38)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Spacer()

                // Ícone do microfone
                Image(systemName: "mic.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(.white)

                // Título
                Text("Privacidade e Microfone")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                // Explicação sobre o uso do microfone e privacidade
                Text("Para monitorar o nível de som ao seu redor, o SensorySafe precisa acessar o microfone do seu dispositivo. Nenhum áudio é gravado, armazenado ou compartilhado. Tudo acontece em tempo real e apenas no seu aparelho, garantindo sua privacidade.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.85))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                // Botão "Permitir acesso" estilizado como seta ou texto
                HStack {
                    Spacer()
                    Button(action: requestMicrophonePermission) {
                        HStack(spacing: 8) {
                            Text("Permitir")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.purple)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                    }
                    .padding(.trailing, 30)
                    .padding(.bottom, 40)
                }
            }
            .padding(.horizontal, 30)
        }
        .alert("Microfone necessário", isPresented: $showDeniedAlert) {
            Button("OK", role: .cancel) {
                // Mesmo sem permissão, segue para Home (estado desabilitado)
                onFinish()
            }
        } message: {
            Text("Sem acesso ao microfone, o SensorySafe não poderá analisar o som ambiente. Você pode ativar a permissão nos Ajustes do iPhone.")
        }
    }

    // Função que solicita a permissão do microfone
    private func requestMicrophonePermission() {
        AVAudioApplication.requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    // Permissão concedida: segue para Home
                    onFinish()
                } else {
                    // Negado: exibe alerta antes de prosseguir
                    showDeniedAlert = true
                }
            }
        }
    }
}

// Preview
#Preview {
    OnboardingMicrophoneView(onFinish: {})
}

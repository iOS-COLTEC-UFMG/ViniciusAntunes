//
//  HomeView.swift
//  trabalho-final
//
//  Created by coltec on 14/05/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var audioVM = AudioLevelViewModel()

    var body: some View {
        ZStack {
            backgroundColor(for: audioVM.levelState)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: audioVM.levelState)

            VStack(spacing: 24) {
                Spacer()

                // ⬇️ Indicador visual: círculo pulsante que substitui o ícone de escudo
                SoundLevelCircle(state: audioVM.levelState, decibels: audioVM.currentDecibels)

                // Valor em dB exibido abaixo do círculo
                Text("\(Int(audioVM.currentDecibels)) dB SPL")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)

                // Cartão informativo (mantido igual)
                VStack(spacing: 16) {
                    Text(titleForState(audioVM.levelState))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Text(descriptionForState(audioVM.levelState))
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)

                    Divider()
                        .background(Color.white.opacity(0.3))

                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        Text("Dica:")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text(tipForState(audioVM.levelState))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .font(.callout)
                }
                .padding(24)
                .background(Color.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 30)

                Spacer()
            }
        }
        .onAppear {
            audioVM.startMonitoring()
        }
        .onDisappear {
            audioVM.stopMonitoring()
        }
    }
}

// Os métodos auxiliares (backgroundColor, titleForState, descriptionForState, tipForState) permanecem IGUAIS.
// Não vou repeti-los aqui para economizar espaço; apenas mantenha os que já estão no seu arquivo HomeView.swift.

// MARK: - Helpers para UI baseada no estado
extension HomeView {
    /// Define a cor de fundo conforme o estado
    func backgroundColor(for state: SoundLevelState) -> Color {
        switch state {
        case .comfortable:
            return Color(red: 0.2, green: 0.6, blue: 0.4) // Verde
        case .attention:
            return Color(red: 1.0, green: 0.75, blue: 0.1) // Amarelo/laranja
        case .risk:
            return Color(red: 0.8, green: 0.2, blue: 0.2) // Vermelho
        case .disabled:
            return Color.gray
        }
    }

    /// Ícone representativo do estado
    func iconForState(_ state: SoundLevelState) -> String {
        switch state {
        case .comfortable: return "checkmark.shield.fill"
        case .attention: return "exclamationmark.shield.fill"
        case .risk: return "xmark.shield.fill"
        case .disabled: return "mic.slash.fill"
        }
    }

    func titleForState(_ state: SoundLevelState) -> String {
        switch state {
        case .comfortable: return "Ambiente Confortável"
        case .attention: return "Atenção Necessária"
        case .risk: return "Risco de Sobrecarga"
        case .disabled: return "Microfone desabilitado"
        }
    }

    func descriptionForState(_ state: SoundLevelState) -> String {
        switch state {
        case .comfortable:
            return "O nível de som ao seu redor está baixo e estável. Este é um local seguro para sua permanência por longos períodos, sem risco imediato de sobrecarga sensorial."
        case .attention:
            return "O volume do ambiente subiu e pode começar a causar desconforto em breve. Monitore como você se sente e avalie se precisará de uma pausa em um local mais silencioso."
        case .risk:
            return "Os níveis de som estão elevados e podem causar dor ou exaustão sensorial. Sua segurança e bem-estar são as prioridades agora; considere sair deste local."
        case .disabled:
            return "O microfone não está acessível. Para ativar o monitoramento, permita o acesso ao microfone nos Ajustes do iPhone."
        }
    }

    func tipForState(_ state: SoundLevelState) -> String {
        switch state {
        case .comfortable: return "Aproveite este momento de calma."
        case .attention: return "Tenha seus protetores auriculares ao alcance."
        case .risk: return "Recomendado buscar um local silencioso imediatamente."
        case .disabled: return "Ajustes > Privacidade > Microfone"
        }
    }
}

// Preview
#Preview {
    HomeView()
}

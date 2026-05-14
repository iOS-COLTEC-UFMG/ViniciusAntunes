//
//  AudioLevelViewModel.swift
//  trabalho-final
//
//  Created by coltec on 14/05/26.
//

import AVFoundation
import Combine

enum SoundLevelState {
    case comfortable
    case attention
    case risk
    case disabled
}

class AudioLevelViewModel: ObservableObject {
    @Published var currentDecibels: Double = 0.0
    @Published var levelState: SoundLevelState = .disabled

    private let audioEngine = AVAudioEngine()

    // Fila de valores recentes para suavização (média móvel)
    private var recentDecibels: [Float] = []
    private let smoothingWindow = 5 // número de amostras para média

    // Timers para atrasar a descida de estado
    private var attentionToComfortableWorkItem: DispatchWorkItem?
    private var riskToAttentionWorkItem: DispatchWorkItem?

    // Duração mínima que o estado elevado deve ser mantido (em segundos)
    private let minAttentionDuration: TimeInterval = 5.0
    private let minRiskDuration: TimeInterval = 10.0

    // Estado atual real (antes do atraso)
    private var rawState: SoundLevelState = .disabled

    func startMonitoring() {
        guard !audioEngine.isRunning else { return }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Erro ao configurar sessão de áudio: \(error)")
            levelState = .disabled
            return
        }

        let inputNode = audioEngine.inputNode
        let bus = 0
        let format = inputNode.outputFormat(forBus: bus)

        inputNode.installTap(onBus: bus, bufferSize: 1024, format: format) { buffer, _ in
            guard let channelData = buffer.floatChannelData?[0] else { return }
            let frameLength = Int(buffer.frameLength)
            var sum: Float = 0
            for i in 0..<frameLength {
                let sample = channelData[i]
                sum += sample * sample
            }
            let rms = sqrt(sum / Float(frameLength))
            let dbFS = 20 * log10(max(rms, 1e-10))
            let estimatedSPL = dbFS + 80

            DispatchQueue.main.async {
                self.processNewDecibelValue(estimatedSPL)
            }
        }

        do {
            try audioEngine.start()
            rawState = .comfortable
            levelState = .comfortable
        } catch {
            print("Falha ao iniciar o engine de áudio: \(error)")
            levelState = .disabled
        }
    }

    func stopMonitoring() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        attentionToComfortableWorkItem?.cancel()
        riskToAttentionWorkItem?.cancel()
    }

    // MARK: - Processamento com histerese temporal
    private func processNewDecibelValue(_ db: Float) {
        // 1. Suaviza o valor (média móvel)
        recentDecibels.append(db)
        if recentDecibels.count > smoothingWindow {
            recentDecibels.removeFirst()
        }
        let smoothedDB = recentDecibels.reduce(0, +) / Float(recentDecibels.count)
        currentDecibels = Double(smoothedDB)

        // 2. Determina o estado "bruto" baseado apenas no nível atual
        let newRawState: SoundLevelState
        if smoothedDB < 55 {
            newRawState = .comfortable
        } else if smoothedDB < 75 {
            newRawState = .attention
        } else {
            newRawState = .risk
        }

        // 3. Aplica histerese temporal (sobe imediatamente, desce com atraso)
        applyTemporalHysteresis(newRawState: newRawState)
    }

    private func applyTemporalHysteresis(newRawState: SoundLevelState) {
        // Se o estado bruto é mais grave (maior alerta), atualiza imediatamente
        if newRawState == .risk && rawState != .risk {
            // Cancelamos qualquer timer de descida pendente
            riskToAttentionWorkItem?.cancel()
            attentionToComfortableWorkItem?.cancel()
            rawState = .risk
            levelState = .risk
        } else if newRawState == .attention && rawState == .comfortable {
            // De confortável para atenção: sobe imediatamente
            attentionToComfortableWorkItem?.cancel()
            rawState = .attention
            levelState = .attention
        } else if newRawState == .attention && rawState == .risk {
            // Estava em risco e agora o som caiu para nível de atenção
            // Agenda transição de risco -> atenção após minRiskDuration
            if riskToAttentionWorkItem == nil {
                let workItem = DispatchWorkItem { [weak self] in
                    guard let self = self else { return }
                    // Verifica se o estado bruto ainda é atenção (não voltou a risco)
                    if self.rawState == .risk {
                        self.rawState = .attention
                        self.levelState = .attention
                        self.riskToAttentionWorkItem = nil
                    }
                }
                riskToAttentionWorkItem = workItem
                DispatchQueue.main.asyncAfter(deadline: .now() + minRiskDuration, execute: workItem)
            }
        } else if newRawState == .comfortable && rawState != .comfortable {
            // Som baixou para confortável, agenda a transição da atenção/risco para confortável
            // Cancelamos trabalho anterior de descida de atenção se existir
            if rawState == .attention {
                if attentionToComfortableWorkItem == nil {
                    let workItem = DispatchWorkItem { [weak self] in
                        guard let self = self else { return }
                        if self.rawState == .attention {
                            self.rawState = .comfortable
                            self.levelState = .comfortable
                            self.attentionToComfortableWorkItem = nil
                        }
                    }
                    attentionToComfortableWorkItem = workItem
                    DispatchQueue.main.asyncAfter(deadline: .now() + minAttentionDuration, execute: workItem)
                }
            } else if rawState == .risk {
                // Se estava em risco e agora som está confortável (muito improvável, mas tratamos)
                // Primeiro agenda a descida de risco para atenção (se não já agendada)
                if riskToAttentionWorkItem == nil {
                    let workItem = DispatchWorkItem { [weak self] in
                        guard let self = self else { return }
                        if self.rawState == .risk {
                            self.rawState = .attention
                            self.levelState = .attention
                            self.riskToAttentionWorkItem = nil
                            // Depois de virar atenção, agenda a descida para confortável
                            self.scheduleComfortableAfterAttention()
                        }
                    }
                    riskToAttentionWorkItem = workItem
                    DispatchQueue.main.asyncAfter(deadline: .now() + minRiskDuration, execute: workItem)
                }
            }
        }

        // Se o estado bruto é menor e estamos em processo de descida, não faz nada (timer já trata)
    }

    private func scheduleComfortableAfterAttention() {
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            if self.rawState == .attention {
                self.rawState = .comfortable
                self.levelState = .comfortable
                self.attentionToComfortableWorkItem = nil
            }
        }
        attentionToComfortableWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + minAttentionDuration, execute: workItem)
    }
}

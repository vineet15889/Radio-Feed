//
//  RecordViewModel.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import Foundation
import Observation
import SwiftUI


enum RecordingState: Equatable {
    case idle
    case requestingPermission
    case recording(duration: TimeInterval)
    case finishing
    case saved(AudioPost)
    case error(String)
}


@Observable
final class RecordViewModel {

    private(set) var state: RecordingState = .idle

    var shouldAutoStart: Bool = false

    private let recordAudioUseCase: RecordAudioUseCase
    private var durationTimer: Timer?

    var isRecording: Bool {
        if case .recording = state { return true }
        return false
    }

    var isLoading: Bool {
        state == .requestingPermission || state == .finishing
    }

    var recordingDuration: TimeInterval {
        if case .recording(let d) = state { return d }
        return 0
    }

    var formattedDuration: String {
        let d = recordingDuration
        return String(format: "%02d.%d", Int(d), Int((d - Double(Int(d))) * 10))
    }

    var remainingTime: TimeInterval {
        max(0, 30 - recordingDuration)
    }

    init(recordAudioUseCase: RecordAudioUseCase) {
        self.recordAudioUseCase = recordAudioUseCase
    }

    func toggleRecording() async {
        if isRecording {
            await finishRecording()
        } else {
            await beginRecording()
        }
    }

    private func beginRecording() async {
        state = .requestingPermission

        guard await recordAudioUseCase.requestPermission() else {
            state = .error("Microphone access denied.\nEnable it in Settings to record.")
            return
        }

        do {
            try await recordAudioUseCase.startRecording()
            state = .recording(duration: 0)
            startTimer()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    private func finishRecording() async {
        stopTimer()
        state = .finishing

        do {
            let post = try await recordAudioUseCase.stopRecording()
            withAnimation(DesignSystem.Anim.spring) {
                state = .saved(post)
            }
            try? await Task.sleep(for: .seconds(1.8))
            withAnimation(DesignSystem.Anim.standard) {
                state = .idle
            }
        } catch {
            state = .error("Failed to save your recording.")
        }
    }

    private func startTimer() {
        durationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self else { return }
            let elapsed = self.recordAudioUseCase.recordingDuration

            if elapsed >= 30 {
                self.stopTimer()
                Task { await self.finishRecording() }
                return
            }
            self.state = .recording(duration: elapsed)
        }
    }

    private func stopTimer() {
        durationTimer?.invalidate()
        durationTimer = nil
    }
}

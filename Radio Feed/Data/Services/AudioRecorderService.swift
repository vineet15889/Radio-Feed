//
//  AudioRecorderService.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import Foundation
import AVFoundation

enum AudioRecorderError: LocalizedError {
    case permissionDenied
    case sessionSetupFailed(Error)
    case recordingStartFailed(Error)
    case noActiveRecording

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Microphone access denied. Enable it in Settings."
        case .sessionSetupFailed(let e):
            return "Audio session error: \(e.localizedDescription)"
        case .recordingStartFailed(let e):
            return "Could not start recording: \(e.localizedDescription)"
        case .noActiveRecording:
            return "No recording is currently in progress."
        }
    }
}


final class AudioRecorderService: NSObject {
    private let storage: AudioS3Store

    private var recorder: AVAudioRecorder?
    private var currentFileURL: URL?
    private var recordingStartTime: Date?
    private var durationTimer: Timer?

    private(set) var isRecording = false
    private(set) var recordingDuration: TimeInterval = 0

    var onMaxDurationReached: (() -> Void)?

    private static let maxDuration: TimeInterval = 30

    init(storage: AudioS3Store) {
        self.storage = storage
    }

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            } else {
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    func startRecording() throws -> URL {
        let session = AVAudioSession.sharedInstance()
        do {
            try session
                .setCategory(
                    .playAndRecord,
                    mode: .default,
                    options: [
                        .defaultToSpeaker,
                        .allowBluetoothHFP
                    ]
                )
            try session.setActive(true)
        } catch {
            throw AudioRecorderError.sessionSetupFailed(error)
        }

        let fileURL = storage.newFileURL()
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            recorder = try AVAudioRecorder(url: fileURL, settings: settings)
            recorder?.delegate = self
            recorder?.isMeteringEnabled = true
            recorder?.record(forDuration: Self.maxDuration)
        } catch {
            throw AudioRecorderError.recordingStartFailed(error)
        }

        isRecording = true
        currentFileURL = fileURL
        recordingStartTime = Date()
        recordingDuration = 0
        startDurationTimer()
        return fileURL
    }

    func stopRecording() throws -> (url: URL, duration: TimeInterval) {
        guard let url = currentFileURL, isRecording else {
            throw AudioRecorderError.noActiveRecording
        }
        recorder?.stop()
        let capturedDuration = recordingDuration
        cleanupState()
        return (url, capturedDuration)
    }

    private func startDurationTimer() {
        durationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self, let start = self.recordingStartTime else { return }
            self.recordingDuration = Date().timeIntervalSince(start)
        }
    }

    private func cleanupState() {
        isRecording = false
        durationTimer?.invalidate()
        durationTimer = nil
        recorder = nil
        currentFileURL = nil
        recordingStartTime = nil
    }

}

extension AudioRecorderService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        guard flag, isRecording else {
            cleanupState()
            return
        }
        cleanupState()
        onMaxDurationReached?()
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        cleanupState()
    }
}

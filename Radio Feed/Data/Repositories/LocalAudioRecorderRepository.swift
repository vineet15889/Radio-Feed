//
//  LocalAudioRecorderRepository.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import Foundation

protocol AudioRecorderRepositoryProtocol: AnyObject {
    var isRecording: Bool { get }
    var recordingDuration: TimeInterval { get }

    func requestPermission() async -> Bool
    func startRecording() async throws
    func stopRecording() async throws -> AudioPost
}

final class LocalAudioRecorderRepository: AudioRecorderRepositoryProtocol {

    private let service: AudioRecorderService

    var isRecording: Bool { service.isRecording }
    var recordingDuration: TimeInterval { service.recordingDuration }

    init(service: AudioRecorderService) {
        self.service = service
    }

    func requestPermission() async -> Bool {
        await service.requestPermission()
    }

    func startRecording() async throws {
        _ = try service.startRecording()
    }

    func stopRecording() async throws -> AudioPost {
        let (url, duration) = try service.stopRecording()
        return AudioPost(
            id: UUID(),
            title: "Voice note",
            username: "@you",
            fileURL: url,
            duration: duration,
            createdAt: Date()
        )
    }
}

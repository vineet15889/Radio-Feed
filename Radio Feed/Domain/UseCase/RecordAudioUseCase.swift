//
//  RecordAudioUseCase.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import Foundation

final class RecordAudioUseCase {
    private let recorderRepository: AudioRecorderRepositoryProtocol
    private let feedRepository: AudioFeedRepositoryProtocol

    var isRecording: Bool { recorderRepository.isRecording }
    var recordingDuration: TimeInterval { recorderRepository.recordingDuration }

    init(
        recorderRepository: AudioRecorderRepositoryProtocol,
        feedRepository: AudioFeedRepositoryProtocol
    ) {
        self.recorderRepository = recorderRepository
        self.feedRepository = feedRepository
    }

    func requestPermission() async -> Bool {
        await recorderRepository.requestPermission()
    }

    func startRecording() async throws {
        try await recorderRepository.startRecording()
    }

    func stopRecording() async throws -> AudioPost {
        let post = try await recorderRepository.stopRecording()
        try await feedRepository.addPost(post)
        return post
    }
}

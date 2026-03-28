//
//  SeekAudioUseCase.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import Foundation

final class SeekAudioUseCase {
    private let playbackRepository: AudioPlaybackRepositoryProtocol

    init(playbackRepository: AudioPlaybackRepositoryProtocol) {
        self.playbackRepository = playbackRepository
    }

    func execute(progress: Double) {
        playbackRepository.seek(to: progress)
    }
}

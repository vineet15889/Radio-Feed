//
//  StopAudioUseCase.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import Foundation

final class StopAudioUseCase {
    private let playbackRepository: AudioPlaybackRepositoryProtocol

    init(playbackRepository: AudioPlaybackRepositoryProtocol) {
        self.playbackRepository = playbackRepository
    }

    func execute() {
        playbackRepository.stop()
    }
}

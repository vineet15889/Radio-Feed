//
//  PlayAudioUseCase.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import Foundation
import Combine

protocol AudioPlaybackRepositoryProtocol: AnyObject {
    var currentPlayingIDPublisher: AnyPublisher<UUID?, Never> { get }
    var isPlayingPublisher: AnyPublisher<Bool, Never> { get }
    var playbackProgressPublisher: AnyPublisher<Double, Never> { get }

    func play(post: AudioPost) throws
    func pause()
    func resume()
    func stop()
    func togglePlayback(for post: AudioPost) throws
}


final class PlayAudioUseCase {
    private let playbackRepository: AudioPlaybackRepositoryProtocol

    init(playbackRepository: AudioPlaybackRepositoryProtocol) {
        self.playbackRepository = playbackRepository
    }

    func execute(post: AudioPost) throws {
        try playbackRepository.togglePlayback(for: post)
    }
}

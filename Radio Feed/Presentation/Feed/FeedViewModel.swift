//
//  FeedViewModel.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import Foundation
import Combine
import Observation

enum FeedDisplayMode: Equatable {
    case card
    case list
}

@Observable
final class FeedViewModel {

    private(set) var posts: [AudioPost] = []
    private(set) var currentPlayingID: UUID?
    private(set) var isPlaying: Bool = false
    private(set) var playbackProgress: Double = 0
    private(set) var errorMessage: String?

    var displayMode: FeedDisplayMode = .card


    private let playAudioUseCase: PlayAudioUseCase
    private let stopAudioUseCase: StopAudioUseCase
    private let seekAudioUseCase: SeekAudioUseCase
    private var cancellables = Set<AnyCancellable>()


    init(
        feedRepository: AudioFeedRepositoryProtocol,
        fetchFeedUseCase: FetchAudioFeedUseCase,
        playAudioUseCase: PlayAudioUseCase,
        stopAudioUseCase: StopAudioUseCase,
        seekAudioUseCase: SeekAudioUseCase,
        playbackRepository: AudioPlaybackRepositoryProtocol
    ) {
        self.playAudioUseCase = playAudioUseCase
        self.stopAudioUseCase = stopAudioUseCase
        self.seekAudioUseCase = seekAudioUseCase

        bindFeedUpdates(from: feedRepository)
        bindPlaybackState(from: playbackRepository)
    }

    // MARK: - Intent

    func togglePlayback(for post: AudioPost) {
        do {
            try playAudioUseCase.execute(post: post)
            errorMessage = nil
        } catch AudioPlayerError.fileNotFound {
            errorMessage = "Audio file not found."
        } catch {
            errorMessage = "Playback failed. Try again."
        }
    }

    func stopPlayback() {
        stopAudioUseCase.execute()
    }

    func seek(to progress: Double, for post: AudioPost) {
        guard currentPlayingID == post.id else { return }
        seekAudioUseCase.execute(progress: progress)
    }

    func clearError() {
        errorMessage = nil
    }

    func toggleDisplayMode() {
        displayMode = displayMode == .card ? .list : .card
    }

    func autoPlay(_ post: AudioPost) {
        guard currentPlayingID != post.id || !isPlaying else { return }
        stopPlayback()
        do { try playAudioUseCase.execute(post: post) } catch { /* silent */ }
    }

    // MARK: - Convenience for views

    func isPostPlaying(_ post: AudioPost) -> Bool {
        currentPlayingID == post.id && isPlaying
    }

    func isPostActive(_ post: AudioPost) -> Bool {
        currentPlayingID == post.id
    }

    func progressFor(_ post: AudioPost) -> Double {
        currentPlayingID == post.id ? playbackProgress : 0
    }

    private func bindFeedUpdates(from repository: AudioFeedRepositoryProtocol) {
        repository.postsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] posts in self?.posts = posts }
            .store(in: &cancellables)
    }

    private func bindPlaybackState(from repository: AudioPlaybackRepositoryProtocol) {
        repository.currentPlayingIDPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] id in self?.currentPlayingID = id }
            .store(in: &cancellables)

        repository.isPlayingPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] playing in self?.isPlaying = playing }
            .store(in: &cancellables)

        repository.playbackProgressPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] progress in self?.playbackProgress = progress }
            .store(in: &cancellables)
    }
}

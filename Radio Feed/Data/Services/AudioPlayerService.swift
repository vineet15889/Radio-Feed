//
//  AudioPlayerService.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import Foundation
import AVFoundation
import Combine
import MediaPlayer

enum AudioPlayerError: LocalizedError {
    case fileNotFound
    case sessionSetupFailed(Error)
    case playbackFailed(Error)

    var errorDescription: String? {
        switch self {
        case .fileNotFound:        return "Audio file not found."
        case .sessionSetupFailed(let e): return "Session error: \(e.localizedDescription)"
        case .playbackFailed(let e):     return "Playback failed: \(e.localizedDescription)"
        }
    }
}

final class AudioPlayerService: NSObject {

    private var player: AVAudioPlayer?
    private var progressTimer: Timer?
    private var currentPost: AudioPost?

    private let currentPlayingIDSubject  = CurrentValueSubject<UUID?,  Never>(nil)
    private let isPlayingSubject         = CurrentValueSubject<Bool,   Never>(false)
    private let playbackProgressSubject  = CurrentValueSubject<Double, Never>(0)

    override init() {
        super.init()
        configureAudioSession()
        configureRemoteCommandCenter()
        observeInterruptions()
    }

    // MARK: - Session & remote controls

    private func configureAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    private func configureRemoteCommandCenter() {
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.isEnabled = true
        center.playCommand.addTarget { [weak self] _ in
            self?.resume()
            return .success
        }

        center.pauseCommand.isEnabled = true
        center.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }

        center.stopCommand.isEnabled = true
        center.stopCommand.addTarget { [weak self] _ in
            self?.stop()
            return .success
        }

        center.nextTrackCommand.isEnabled  = false
        center.previousTrackCommand.isEnabled = false
    }

    private func observeInterruptions() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    @objc private func handleInterruption(_ notification: Notification) {
        guard
            let info = notification.userInfo,
            let rawType = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: rawType)
        else { return }

        switch type {
        case .began:
            pauseInternal()
        case .ended:
            // Don't auto-resume
            break
        @unknown default:
            break
        }
    }

    // MARK: - Lock-screen (Now Playing) info

    private func updateNowPlayingInfo(post: AudioPost?, playing: Bool) {
        guard let post else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle:                  post.title,
            MPMediaItemPropertyArtist:                 post.username,
            MPMediaItemPropertyPlaybackDuration:       post.duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: player?.currentTime ?? 0,
            MPNowPlayingInfoPropertyPlaybackRate:      playing ? 1.0 : 0.0
        ]
    }

    // MARK: - Internal control

    private func pauseInternal() {
        player?.pause()
        isPlayingSubject.send(false)
        stopProgressTimer()
        updateNowPlayingInfo(post: currentPost, playing: false)
    }

    private func stopInternal() {
        player?.stop()
        player = nil
        currentPost = nil
        currentPlayingIDSubject.send(nil)
        isPlayingSubject.send(false)
        playbackProgressSubject.send(0)
        stopProgressTimer()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    private func startProgressTimer() {
        stopProgressTimer()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self, let player = self.player, player.duration > 0 else { return }
            self.playbackProgressSubject.send(player.currentTime / player.duration)
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - AudioPlaybackRepositoryProtocol

extension AudioPlayerService: AudioPlaybackRepositoryProtocol {

    var currentPlayingIDPublisher: AnyPublisher<UUID?, Never> {
        currentPlayingIDSubject.eraseToAnyPublisher()
    }
    var isPlayingPublisher: AnyPublisher<Bool, Never> {
        isPlayingSubject.eraseToAnyPublisher()
    }
    var playbackProgressPublisher: AnyPublisher<Double, Never> {
        playbackProgressSubject.eraseToAnyPublisher()
    }

    func play(post: AudioPost) throws {
        guard FileManager.default.fileExists(atPath: post.fileURL.path) else {
            throw AudioPlayerError.fileNotFound
        }

        stopInternal()

        do {
            let newPlayer = try AVAudioPlayer(contentsOf: post.fileURL)
            newPlayer.delegate = self
            newPlayer.prepareToPlay()
            newPlayer.play()
            player      = newPlayer
            currentPost = post
            currentPlayingIDSubject.send(post.id)
            isPlayingSubject.send(true)
            startProgressTimer()
            updateNowPlayingInfo(post: post, playing: true)
        } catch {
            throw AudioPlayerError.playbackFailed(error)
        }
    }

    func pause() { pauseInternal() }

    func resume() {
        guard player != nil else { return }
        player?.play()
        isPlayingSubject.send(true)
        startProgressTimer()
        updateNowPlayingInfo(post: currentPost, playing: true)
    }

    func stop() { stopInternal() }

    func togglePlayback(for post: AudioPost) throws {
        if currentPlayingIDSubject.value == post.id {
            isPlayingSubject.value ? pauseInternal() : resume()
        } else {
            try play(post: post)
        }
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioPlayerService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopInternal()
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        stopInternal()
    }
}

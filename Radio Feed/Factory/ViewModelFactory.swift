//
//  ViewModelFactory.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import Foundation
import Combine

final class ViewModelFactory: ObservableObject {

    private let audioS3Store:         AudioS3Store
    private let audioPlayerService:   AudioPlayerService
    private let audioRecorderService: AudioRecorderService
    private let feedRepository:       LocalAudioFeedRepository
    private let recorderRepository:   LocalAudioRecorderRepository

    private let fetchFeedUseCase:   FetchAudioFeedUseCase
    private let recordAudioUseCase: RecordAudioUseCase
    private let playAudioUseCase:   PlayAudioUseCase
    private let stopAudioUseCase:   StopAudioUseCase
    private let seekAudioUseCase:   SeekAudioUseCase

    private(set) lazy var feedViewModel:   FeedViewModel   = makeFeedViewModel()
    private(set) lazy var recordViewModel: RecordViewModel = makeRecordViewModel()

    init() {
        let s3       = AudioS3Store()
        audioS3Store = s3

        let player   = AudioPlayerService()
        let recorder = AudioRecorderService(storage: s3)
        audioPlayerService   = player
        audioRecorderService = recorder

        let feedRepo     = LocalAudioFeedRepository(store: s3)
        let recorderRepo = LocalAudioRecorderRepository(service: recorder)
        feedRepository     = feedRepo
        recorderRepository = recorderRepo

        fetchFeedUseCase   = FetchAudioFeedUseCase(repository: feedRepo)
        recordAudioUseCase = RecordAudioUseCase(recorderRepository: recorderRepo, feedRepository: feedRepo)
        playAudioUseCase   = PlayAudioUseCase(playbackRepository: player)
        stopAudioUseCase   = StopAudioUseCase(playbackRepository: player)
        seekAudioUseCase   = SeekAudioUseCase(playbackRepository: player)
    }


    private func makeFeedViewModel() -> FeedViewModel {
        FeedViewModel(
            feedRepository:    feedRepository,
            fetchFeedUseCase:  fetchFeedUseCase,
            playAudioUseCase:  playAudioUseCase,
            stopAudioUseCase:  stopAudioUseCase,
            seekAudioUseCase:  seekAudioUseCase,
            playbackRepository: audioPlayerService
        )
    }

    private func makeRecordViewModel() -> RecordViewModel {
        RecordViewModel(recordAudioUseCase: recordAudioUseCase)
    }
}

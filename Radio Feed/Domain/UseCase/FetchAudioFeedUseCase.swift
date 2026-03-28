//
//  FetchAudioFeedUseCase.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import Foundation

final class FetchAudioFeedUseCase {
    private let repository: AudioFeedRepositoryProtocol

    init(repository: AudioFeedRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [AudioPost] {
        try await repository.fetchPosts()
    }
}

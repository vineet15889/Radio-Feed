//
//  LocalAudioFeedRepository.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import Foundation
import Combine


protocol AudioFeedRepositoryProtocol: AnyObject {
    var postsPublisher: AnyPublisher<[AudioPost], Never> { get }

    func fetchPosts() async throws -> [AudioPost]
    func addPost(_ post: AudioPost) async throws
}


final class LocalAudioFeedRepository: AudioFeedRepositoryProtocol {

    private let store: AudioS3Store
    private let postsSubject: CurrentValueSubject<[AudioPost], Never>

    var postsPublisher: AnyPublisher<[AudioPost], Never> {
        postsSubject.eraseToAnyPublisher()
    }

    init(store: AudioS3Store) {
        self.store = store
        postsSubject = CurrentValueSubject(store.loadManifest())
    }

    func fetchPosts() async throws -> [AudioPost] {
        postsSubject.value
    }

    func addPost(_ post: AudioPost) async throws {
        var updated = postsSubject.value
        updated.insert(post, at: 0)
        postsSubject.send(updated)
        store.saveManifest(updated)
    }
}

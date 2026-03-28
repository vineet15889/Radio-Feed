//
//  AudioS3Store.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import Foundation

final class AudioS3Store {

    let rootURL: URL

    private let manifestURL: URL

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        rootURL     = docs.appendingPathComponent("AudioS3", isDirectory: true)
        manifestURL = rootURL.appendingPathComponent("manifest.json")
        try? FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
    }

    // MARK: - File storage

    func newFileURL() -> URL {
        rootURL.appendingPathComponent("audio_\(UUID().uuidString).m4a")
    }

    private struct PersistedPost: Codable {
        let id: UUID
        let title: String
        let username: String
        let filename: String
        let duration: TimeInterval
        let createdAt: Date
        
    }

    func loadManifest() -> [AudioPost] {
        guard let data = try? Data(contentsOf: manifestURL) else { return [] }
        let records = (try? decoder.decode([PersistedPost].self, from: data)) ?? []

        return records.compactMap { record in
            // Reconstruct absolute URL from the current sandbox path
            let fileURL = rootURL.appendingPathComponent(record.filename)
            guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
            return AudioPost(
                id:        record.id,
                title:     record.title,
                username:  record.username,
                fileURL:   fileURL,
                duration:  record.duration,
                createdAt: record.createdAt
            )
        }
    }

    func saveManifest(_ posts: [AudioPost]) {
        let records = posts.map { post in
            PersistedPost(
                id:       post.id,
                title:    post.title,
                username: post.username,
                filename: post.fileURL.lastPathComponent,
                duration: post.duration,
                createdAt: post.createdAt
            )
        }
        guard let data = try? encoder.encode(records) else { return }
        try? data.write(to: manifestURL, options: .atomic)
    }
}

//
//  AudioPost.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import Foundation

struct AudioPost: Identifiable, Equatable, Hashable, Sendable, Codable {
    let id: UUID
    let title: String
    let username: String
    let fileURL: URL
    let duration: TimeInterval
    let createdAt: Date
}

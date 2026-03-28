//
//  CardFeedView.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import SwiftUI

struct CardFeedView: View {
    @Environment(FeedViewModel.self) private var viewModel

    @State private var currentID: UUID?

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.posts) { post in
                    AudioCardView(
                        post: post,
                        isPlaying: viewModel.isPostPlaying(post),
                        isActive: viewModel.isPostActive(post),
                        progress: viewModel.progressFor(post),
                        onTap: { viewModel.togglePlayback(for: post) },
                        onSeek: { viewModel.seek(to: $0, for: post) }
                    )
                    .containerRelativeFrame([.horizontal, .vertical])
                    .id(post.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $currentID)
        .scrollIndicators(.hidden)
        .onChange(of: currentID) { _, newID in
            guard let id = newID,
                  let post = viewModel.posts.first(where: { $0.id == id })
            else { return }
            viewModel.autoPlay(post)
        }
        .onAppear {
            if let first = viewModel.posts.first {
                currentID = first.id
                viewModel.autoPlay(first)
            }
        }
        .onChange(of: viewModel.posts.count) { oldCount, newCount in
            guard newCount > oldCount, currentID == nil else { return }
            currentID = viewModel.posts.first?.id
        }
    }
}

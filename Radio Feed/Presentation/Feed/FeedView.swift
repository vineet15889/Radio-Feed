//
//  FeedView.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import SwiftUI

struct FeedView: View {
    @Environment(FeedViewModel.self) private var viewModel
    @Environment(RecordViewModel.self) private var recordViewModel

    @Binding var selectedTab: Int

    @State private var showError = false

    var body: some View {
        ZStack {
            DesignSystem.Colors.background.ignoresSafeArea()

            Group {
                if viewModel.posts.isEmpty {
                    EmptyFeedView {
                        recordViewModel.shouldAutoStart = true
                        selectedTab = 1
                    }
                    .transition(.opacity)
                } else if viewModel.displayMode == .card {
                    CardFeedView()
                        .transition(.opacity)
                } else {
                    listFeed
                        .transition(.opacity)
                }
            }
            .animation(DesignSystem.Anim.standard, value: viewModel.displayMode)
            .animation(DesignSystem.Anim.standard, value: viewModel.posts.isEmpty)
        }
        .navigationTitle("Radio Feed")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                displayModeToggle
            }
        }
        .onChange(of: viewModel.errorMessage) { _, msg in
            showError = msg != nil
        }
        .alert("Playback Error", isPresented: $showError) {
            Button("OK", role: .cancel) { viewModel.clearError() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var displayModeToggle: some View {
        Button {
            withAnimation(DesignSystem.Anim.spring) {
                viewModel.toggleDisplayMode()
                if viewModel.displayMode == .list {
                    viewModel.stopPlayback()
                }
            }
        } label: {
            Image(systemName: viewModel.displayMode == .card ? "list.bullet" : "square.stack.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(DesignSystem.Colors.accent)
                .contentTransition(.symbolEffect(.replace))
        }
    }

    private var listFeed: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Metrics.cardSpacing) {
                ForEach(viewModel.posts) { post in
                    AudioPostCell(
                        post: post,
                        isPlaying: viewModel.isPostPlaying(post),
                        isActive: viewModel.isPostActive(post),
                        progress: viewModel.progressFor(post),
                        onTap: { viewModel.togglePlayback(for: post) },
                        onSeek: { viewModel.seek(to: $0, for: post) }
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .offset(y: 24)),
                        removal:   .opacity
                    ))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
            .animation(.spring(response: 0.48, dampingFraction: 0.82), value: viewModel.posts.count)
        }
    }
}

private struct EmptyFeedView: View {
    let onTapRecord: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Button(action: onTapRecord) {
                Image(systemName: "waveform.circle")
                    .font(.system(size: 76))
                    .foregroundStyle(DesignSystem.Colors.accent.opacity(0.75))
                    .symbolEffect(.pulse)
            }
            .buttonStyle(.plain)

            Text("No posts yet")
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(DesignSystem.Colors.textPrimary)

            Text("Tap the icon to record your first post")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }
}

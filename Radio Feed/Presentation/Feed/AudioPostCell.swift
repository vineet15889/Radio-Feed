//
//  AudioPostCell.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import SwiftUI

struct AudioPostCell: View {
    let post: AudioPost
    let isPlaying: Bool
    let isActive: Bool
    let progress: Double
    let onTap: () -> Void
    let onSeek: (Double) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                mainRow
                    .padding(DesignSystem.Metrics.cardPadding)
            }
            .buttonStyle(ScaleButtonStyle())

            if isActive {
                SeekBar(progress: progress, onSeek: onSeek)
                    .padding(.horizontal, DesignSystem.Metrics.cardPadding)
                    .padding(.bottom, 12)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .background(cardBackground)
        .animation(DesignSystem.Anim.spring, value: isActive)
        .animation(DesignSystem.Anim.spring, value: isPlaying)
    }

    private var mainRow: some View {
        HStack(spacing: 14) {
            avatarView

            VStack(alignment: .leading, spacing: 5) {
                Text(post.title)
                    .font(DesignSystem.Typography.postTitle)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                    .lineLimit(2)

                Text(post.username)
                    .font(DesignSystem.Typography.username)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)

                Text(formattedDuration)
                    .font(DesignSystem.Typography.duration)
                    .foregroundStyle(DesignSystem.Colors.textSecondary.opacity(0.75))
            }

            Spacer(minLength: 8)

            VStack(spacing: 10) {
                WaveformIndicator(isPlaying: isPlaying)
                playPauseButton
            }
        }
    }

    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(avatarGradient)
                .frame(width: DesignSystem.Metrics.avatarSize, height: DesignSystem.Metrics.avatarSize)

            Text(initials)
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
        }
        .overlay {
            if isPlaying {
                Circle()
                    .stroke(DesignSystem.Colors.accent, lineWidth: 2)
                    .frame(
                        width: DesignSystem.Metrics.avatarSize + 5,
                        height: DesignSystem.Metrics.avatarSize + 5
                    )
            }
        }
        .animation(DesignSystem.Anim.playback, value: isPlaying)
    }

    private var playPauseButton: some View {
        ZStack {
            Circle()
                .fill(isPlaying
                      ? DesignSystem.Colors.accent
                      : DesignSystem.Colors.accent.opacity(0.14))
                .frame(width: DesignSystem.Metrics.playBtnSize,
                       height: DesignSystem.Metrics.playBtnSize)

            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isPlaying ? .white : DesignSystem.Colors.accent)
                .offset(x: isPlaying ? 0 : 1.5) // optical centering for play triangle
        }
        .scaleEffect(isPlaying ? 1.10 : 1.0)
        .animation(DesignSystem.Anim.playback, value: isPlaying)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: DesignSystem.Metrics.cornerRadius)
            .fill(DesignSystem.Colors.cardBg)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Metrics.cornerRadius)
                    .stroke(
                        isActive
                            ? DesignSystem.Colors.accent.opacity(0.45)
                            : DesignSystem.Colors.cardBorder,
                        lineWidth: isActive ? 1.0 : 0.5
                    )
            )
            .shadow(
                color: isActive
                    ? DesignSystem.Colors.accent.opacity(0.18)
                    : .black.opacity(0.22),
                radius: isActive ? 14 : 6,
                y: 3
            )
    }

    // MARK: - Helpers

    private var formattedDuration: String {
        let t = Int(post.duration)
        return String(format: "%d:%02d", t / 60, t % 60)
    }

    private var initials: String {
        let name = post.username.hasPrefix("@")
            ? String(post.username.dropFirst())
            : post.username
        return String(name.prefix(2)).uppercased()
    }

    private var avatarGradient: LinearGradient {
        let palettes: [[Color]] = [
            [.blue, Color(red: 0.5, green: 0.2, blue: 0.9)],
            [.orange, .red],
            [Color(red: 0.1, green: 0.7, blue: 0.5), .teal],
            [Color(red: 0.9, green: 0.3, blue: 0.6), .purple],
            [.indigo, .blue],
        ]
        let idx = abs(post.id.hashValue) % palettes.count
        return LinearGradient(colors: palettes[idx], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.972 : 1.0)
            .animation(.spring(response: 0.30, dampingFraction: 0.70), value: configuration.isPressed)
    }
}

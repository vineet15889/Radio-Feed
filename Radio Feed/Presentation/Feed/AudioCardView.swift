//
//  AudioCardView.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import SwiftUI

struct AudioCardView: View {
    let post: AudioPost
    let isPlaying: Bool
    let isActive: Bool
    let progress: Double
    let onTap: () -> Void
    let onSeek: (Double) -> Void

    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: 0) {
                Spacer()

                centerVisual
                    .padding(.bottom, 36)

                postInfo
                    .padding(.horizontal, 28)
                    .padding(.bottom, 32)

                progressSection
                    .padding(.horizontal, 28)
                    .padding(.bottom, 20)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .onChange(of: isPlaying) { _, playing in
            withAnimation(.easeOut(duration: 1.4).repeatForever(autoreverses: true)) {
                pulseScale = playing ? 1.08 : 1.0
            }
        }
        .onAppear {
            if isPlaying {
                withAnimation(.easeOut(duration: 1.4).repeatForever(autoreverses: true)) {
                    pulseScale = 1.08
                }
            }
        }
    }

    // MARK: - Background

    private var backgroundView: some View {
        ZStack {
            DesignSystem.Colors.background

            // Soft colored haze at the top from avatar palette
            LinearGradient(
                colors: [avatarColors[0].opacity(0.28), .clear],
                startPoint: .top,
                endPoint: .center
            )
        }
        .ignoresSafeArea()
    }

    private var centerVisual: some View {
        ZStack(alignment: .bottom) {
            if isPlaying {
                ForEach(0..<3, id: \.self) { ring in
                    Circle()
                        .stroke(
                            avatarColors[0].opacity(0.12 - Double(ring) * 0.03),
                            lineWidth: 1.5
                        )
                        .frame(
                            width: 118 + CGFloat(ring * 36),
                            height: 118 + CGFloat(ring * 36)
                        )
                        .scaleEffect(pulseScale)
                }
            }

            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: avatarColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 110, height: 110)
                    .shadow(
                        color: avatarColors[0].opacity(isPlaying ? 0.55 : 0.25),
                        radius: isPlaying ? 28 : 10
                    )

                Text(initials)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .scaleEffect(isPlaying ? 1.05 : 1.0)
            .animation(DesignSystem.Anim.spring, value: isPlaying)
            .frame(height: 165, alignment: .top)

            WaveformIndicator(isPlaying: isPlaying, barCount: 7, maxHeight: 26)
                .padding(.bottom, 0)
        }
        .frame(height: 210)
        .animation(DesignSystem.Anim.spring, value: isPlaying)
    }

    private var postInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.title)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                .lineLimit(2)

            HStack(spacing: 6) {
                Text(post.username)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(DesignSystem.Colors.textSecondary)

                Circle()
                    .fill(DesignSystem.Colors.textSecondary)
                    .frame(width: 3, height: 3)

                Text(formattedDuration)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var progressSection: some View {
        VStack(spacing: 16) {
            SeekBar(progress: progress, onSeek: onSeek)

            // Large centred play/pause
            Button(action: onTap) {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.accent)
                        .frame(width: 68, height: 68)
                        .shadow(color: DesignSystem.Colors.accent.opacity(0.50), radius: 18)

                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                        .offset(x: isPlaying ? 0 : 2)
                }
            }
            .buttonStyle(.plain)
            .scaleEffect(isPlaying ? 1.08 : 1.0)
            .animation(DesignSystem.Anim.playback, value: isPlaying)
        }
    }

    private var formattedDuration: String {
        let t = Int(post.duration)
        return String(format: "%d:%02d", t / 60, t % 60)
    }

    private var initials: String {
        let name = post.username.hasPrefix("@") ? String(post.username.dropFirst()) : post.username
        return String(name.prefix(2)).uppercased()
    }

    private var avatarColors: [Color] {
        let palettes: [[Color]] = [
            [.blue, Color(red: 0.5, green: 0.2, blue: 0.9)],
            [.orange, .red],
            [Color(red: 0.1, green: 0.7, blue: 0.5), .teal],
            [Color(red: 0.9, green: 0.3, blue: 0.6), .purple],
            [.indigo, .blue],
        ]
        return palettes[abs(post.id.hashValue) % palettes.count]
    }
}

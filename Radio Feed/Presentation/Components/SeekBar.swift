//
//  SeekBar.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import SwiftUI

struct SeekBar: View {
    let progress: Double
    let onSeek: (Double) -> Void

    @State private var isDragging = false
    @State private var dragProgress: Double = 0

    private var displayProgress: Double { isDragging ? dragProgress : progress }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(DesignSystem.Colors.progressTrack)
                    .frame(height: isDragging ? 5 : 3)
                    .frame(maxWidth: .infinity)

                Capsule()
                    .fill(DesignSystem.Colors.accent)
                    .frame(
                        width: max(0, geo.size.width * displayProgress),
                        height: isDragging ? 5 : 3
                    )
                    .animation(isDragging ? nil : .linear(duration: 0.05), value: displayProgress)

                Circle()
                    .fill(DesignSystem.Colors.accent)
                    .frame(
                        width: isDragging ? 14 : 0,
                        height: isDragging ? 14 : 0
                    )
                    .shadow(color: DesignSystem.Colors.accent.opacity(0.5), radius: 4)
                    .offset(x: isDragging
                            ? max(0, geo.size.width * displayProgress - 7)
                            : 0)
                    .animation(DesignSystem.Anim.spring, value: isDragging)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .highPriorityGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isDragging {
                            dragProgress = progress
                            isDragging = true
                        }
                        dragProgress = max(0, min(1, value.location.x / geo.size.width))
                    }
                    .onEnded { value in
                        let final = max(0, min(1, value.location.x / geo.size.width))
                        onSeek(final)
                        isDragging = false
                    }
            )
        }
        .frame(height: 28)
        .animation(DesignSystem.Anim.spring, value: isDragging)
    }
}

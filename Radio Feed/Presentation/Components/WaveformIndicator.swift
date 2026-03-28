//
//  WaveformIndicator.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import SwiftUI
import Combine

struct WaveformIndicator: View {
    var isPlaying: Bool
    var barCount: Int = 5
    var color: Color = DesignSystem.Colors.accent
    var maxHeight: CGFloat = 20

    @State private var heights: [CGFloat] = [0.40, 0.72, 0.50, 0.90, 0.60]

    private let ticker = Timer.publish(every: 0.13, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<barCount, id: \.self) { i in
                Capsule()
                    .fill(color)
                    .frame(width: 3, height: heights[i % heights.count] * maxHeight + 3)
                    .animation(.easeInOut(duration: 0.13), value: heights[i % heights.count])
            }
        }
        .opacity(isPlaying ? 1 : 0.25)
        .animation(DesignSystem.Anim.standard, value: isPlaying)
        .onReceive(ticker) { _ in
            guard isPlaying else { return }
            heights = (0..<barCount).map { _ in CGFloat.random(in: 0.15...1.0) }
        }
    }
}

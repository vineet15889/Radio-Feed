//
//  DesignSystem.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import SwiftUI

enum DesignSystem {

    enum Colors {
        static let background = Color(red: 0.04, green: 0.04, blue: 0.07)
        static let cardBg = Color(red: 0.09, green: 0.09, blue: 0.13)
        static let cardBorder = Color(white: 0.16)
        static let accent = Color(red: 0.28, green: 0.57, blue: 1.00)
        static let recordAccent = Color(red: 1.00, green: 0.33, blue: 0.33)
        static let textPrimary = Color.white
        static let textSecondary = Color(white: 0.52)
        static let progressTrack = Color(white: 0.20)
    }

    enum Typography {
        static let postTitle  = Font.system(.headline, design: .rounded, weight: .semibold)
        static let username = Font.system(.subheadline, design: .rounded, weight: .medium)
        static let duration = Font.system(.caption, design: .monospaced)
        static let timer = Font.system(size: 52, weight: .thin, design: .monospaced)
    }

    enum Metrics {
        static let cardPadding: CGFloat = 16
        static let cardSpacing: CGFloat = 12
        static let cornerRadius: CGFloat = 20
        static let avatarSize: CGFloat = 46
        static let playBtnSize: CGFloat = 40
    }

    enum Anim {
        static let standard = Animation.easeInOut(duration: 0.22)
        static let spring = Animation.spring(response: 0.38, dampingFraction: 0.72)
        static let playback = Animation.easeInOut(duration: 0.18)
    }
}

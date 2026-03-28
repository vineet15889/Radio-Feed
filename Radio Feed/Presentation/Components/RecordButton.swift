//
//  RecordButton.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import SwiftUI

struct RecordButton: View {
    var isRecording: Bool
    var isLoading: Bool
    var action: () -> Void

    @State private var haloScale: CGFloat = 1.0
    @State private var haloOpacity: Double = 0.55

    private var buttonColor: Color {
        isRecording ? DesignSystem.Colors.recordAccent : DesignSystem.Colors.accent
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                if isRecording {
                    Circle()
                        .stroke(DesignSystem.Colors.recordAccent.opacity(0.25), lineWidth: 14)
                        .scaleEffect(haloScale)
                        .opacity(haloOpacity)
                }

                Circle()
                    .stroke(buttonColor.opacity(0.35), lineWidth: 2)
                    .frame(width: 96, height: 96)
                    .scaleEffect(isRecording ? 1.06 : 1.0)
                    .animation(DesignSystem.Anim.spring, value: isRecording)

                Circle()
                    .fill(buttonColor)
                    .frame(width: 80, height: 80)
                    .shadow(color: buttonColor.opacity(0.55), radius: isRecording ? 24 : 12)
                    .overlay {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundStyle(.white)
                                .scaleEffect(isRecording ? 0.72 : 1.0)
                                .animation(DesignSystem.Anim.spring, value: isRecording)
                        }
                    }
                    .scaleEffect(isRecording ? 1.05 : 1.0)
                    .animation(DesignSystem.Anim.spring, value: isRecording)
            }
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .onChange(of: isRecording) { _, recording in
            if recording { startHalo() }
        }
        .onAppear { if isRecording { startHalo() } }
    }

    private func startHalo() {
        haloScale = 1.0
        haloOpacity = 0.55
        withAnimation(.easeOut(duration: 1.3).repeatForever(autoreverses: false)) {
            haloScale = 1.6
            haloOpacity = 0
        }
    }
}

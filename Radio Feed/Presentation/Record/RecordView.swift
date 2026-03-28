//
//  RecordView.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import SwiftUI

struct RecordView: View {
    @Environment(RecordViewModel.self) private var viewModel

    var body: some View {
        ZStack {
            DesignSystem.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                timerSection
                    .padding(.bottom, 52)

                ZStack {
                    if viewModel.isRecording {
                        progressArc
                    }

                    RecordButton(
                        isRecording: viewModel.isRecording,
                        isLoading: viewModel.isLoading,
                        action: {
                            Task { await viewModel.toggleRecording() }
                        }
                    )
                }

                hintLabel
                    .padding(.top, 28)

                Spacer()
                Spacer()
            }
        }
        .navigationTitle("Record")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            guard viewModel.shouldAutoStart else { return }
            viewModel.shouldAutoStart = false
            Task { await viewModel.toggleRecording() }
        }
    }

    private var timerSection: some View {
        Group {
            switch viewModel.state {
            case .idle:
                Text("00.0")
                    .font(DesignSystem.Typography.timer)
                    .foregroundStyle(DesignSystem.Colors.textSecondary.opacity(0.35))
                    .monospacedDigit()

            case .requestingPermission:
                Text("Requesting access…")
                    .font(.system(.title2, design: .rounded, weight: .light))
                    .foregroundStyle(DesignSystem.Colors.textSecondary)

            case .recording:
                VStack(spacing: 8) {
                    Text(viewModel.formattedDuration)
                        .font(DesignSystem.Typography.timer)
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                        .monospacedDigit()
                        .contentTransition(.numericText(countsDown: false))

                    Text("\(Int(viewModel.remainingTime))s left")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(
                            viewModel.remainingTime <= 10
                                ? DesignSystem.Colors.recordAccent
                                : DesignSystem.Colors.textSecondary
                        )
                        .animation(DesignSystem.Anim.standard, value: viewModel.remainingTime <= 10)
                }

            case .finishing:
                Text("Saving…")
                    .font(.system(.title2, design: .rounded, weight: .light))
                    .foregroundStyle(DesignSystem.Colors.textSecondary)

            case .saved:
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(DesignSystem.Colors.accent)
                    Text("Saved to feed!")
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                }
                .font(.system(.title2, design: .rounded, weight: .semibold))

            case .error(let msg):
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 32))
                        .foregroundStyle(DesignSystem.Colors.recordAccent)

                    Text(msg)
                        .font(.system(.callout, design: .rounded))
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
        }
        .animation(DesignSystem.Anim.spring, value: viewModel.state)
    }

    private var progressArc: some View {
        Circle()
            .trim(from: 0, to: viewModel.recordingDuration / 30)
            .stroke(
                DesignSystem.Colors.recordAccent,
                style: StrokeStyle(lineWidth: 3, lineCap: .round)
            )
            .frame(width: 114, height: 114)
            .rotationEffect(.degrees(-90))
            .animation(.linear(duration: 0.05), value: viewModel.recordingDuration)
    }

    private var hintLabel: some View {
        Text(viewModel.isRecording ? "Tap to stop" : "Tap to start recording")
            .font(.system(.subheadline, design: .rounded))
            .foregroundStyle(DesignSystem.Colors.textSecondary)
            .animation(DesignSystem.Anim.standard, value: viewModel.isRecording)
    }
}

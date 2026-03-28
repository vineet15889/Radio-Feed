//
//  ContentView.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(FeedViewModel.self) private var feedViewModel

    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                FeedView(selectedTab: $selectedTab)
            }
            .tag(0)
            .tabItem {
                Label("Feed", systemImage: "waveform")
            }

            NavigationStack {
                RecordView()
            }
            .tag(1)
            .tabItem {
                Label("Record", systemImage: "mic.circle.fill")
            }
        }
        .tint(DesignSystem.Colors.accent)
        .preferredColorScheme(.dark)
        .onChange(of: selectedTab) { _, tab in
            if tab == 1 { feedViewModel.stopPlayback() }
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .background:
                // .playback session keeps audio alive in background.
                break
            default:
                break
            }
        }
    }
}

#Preview {
    ContentView()
}

//
//  Radio_FeedApp.swift
//  Radio Feed
//
//  Created by Vineet Rai on 28-Mar-26.
//

import SwiftUI

@main
struct Radio_FeedApp: App {
    @StateObject private var factory = ViewModelFactory()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(factory.feedViewModel)
                .environment(factory.recordViewModel)
        }
    }
}

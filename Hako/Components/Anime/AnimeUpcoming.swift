//
//  AnimeUpcoming.swift
//  Hako
//
//  Created by Gao Tianrun on 26/3/26.
//

import SwiftUI

struct AnimeUpcoming: View {
    private let nextEpisode: NextAiringEpisode?
    private let load: () async -> Void
    
    init(nextEpisode: NextAiringEpisode?, load: @escaping () async -> Void) {
        self.nextEpisode = nextEpisode
        self.load = load
    }
    
    var body: some View {
        VStack {
            if let nextEpisode = nextEpisode {
                ScrollViewSection(title: "Upcoming") {
                    ScrollViewRow("Episode \(nextEpisode.episode) at \(Date(timeIntervalSince1970: TimeInterval(nextEpisode.airingAt)).toFullString())")
                }
            }
        }
        .task {
            await load()
        }
    }
}

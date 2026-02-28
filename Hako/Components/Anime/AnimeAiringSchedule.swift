//
//  AnimeAiringInformation.swift
//  Hako
//
//  Created by Gao Tianrun on 15/6/25.
//

import SwiftUI

struct AnimeAiringSchedule: View {
    private let nextEpisode: NextAiringEpisode?
    private let load: () async -> Void
    
    init(nextEpisode: NextAiringEpisode?, load: @escaping () async -> Void) {
        self.nextEpisode = nextEpisode
        self.load = load
    }
    
    var body: some View {
        VStack {
            if let nextEpisode = nextEpisode {
                ScrollViewSection(title: "Airing") {
                    ScrollViewRow(title: "Next episode", content: String(nextEpisode.episode))
                    ScrollViewRow(title: "Airing at", content: Date(timeIntervalSince1970: TimeInterval(nextEpisode.airingAt)).toFullString())
                }
            }
        }
        .task {
            await load()
        }
    }
}

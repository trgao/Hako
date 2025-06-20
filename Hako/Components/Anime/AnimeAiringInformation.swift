//
//  AnimeAiringInformation.swift
//  Hako
//
//  Created by Gao Tianrun on 15/6/25.
//

import SwiftUI

struct AnimeAiringInformation: View {
    private var nextEpisode: NextAiringEpisode?
    
    init(nextEpisode: NextAiringEpisode?) {
        self.nextEpisode = nextEpisode
    }
    
    var body: some View {
        if let nextEpisode = nextEpisode {
            ScrollViewSection(title: "Airing") {
                ScrollViewRow(title: "Next episode", content: nextEpisode.episode)
                ScrollViewRow(title: "Airing at", content: Date(timeIntervalSince1970: TimeInterval(nextEpisode.airingAt)).toFullString())
            }
        }
    }
}

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
            Section {
                ListRow(title: "Next episode", content: nextEpisode.episode)
                ListRow(title: "Airing at", content: Date(timeIntervalSince1970: TimeInterval(nextEpisode.airingAt)).toFullString())
            } header: {
                Text("Airing schedule")
                    .textCase(nil)
                    .foregroundColor(Color.primary)
                    .font(.system(size: 17))
                    .bold()
            }
        }
    }
}

//
//  Upcoming.swift
//  Hako
//
//  Created by Gao Tianrun on 26/3/26.
//

import SwiftUI

struct Upcoming: View {
    private let nextEpisode: NextAiringEpisode?
    private let load: () async -> Void
    
    init(nextEpisode: NextAiringEpisode?, load: @escaping () async -> Void) {
        self.nextEpisode = nextEpisode
        self.load = load
    }
    
    var body: some View {
        VStack {
            if let nextEpisode = nextEpisode {
                let airingDate = Date(timeIntervalSince1970: TimeInterval(nextEpisode.airingAt))
                let timeToAiring = Calendar(identifier: .gregorian).dateComponents([.day, .hour], from: Date(), to: airingDate)
                var timeToAiringString: String {
                    var result = ""
                    if let day = timeToAiring.day, day > 0 {
                        result += "\(day) day\(day == 1 ? "" : "s")"
                        if let hour = timeToAiring.hour, hour > 0 {
                            result += " "
                        }
                    }
                    if let hour = timeToAiring.hour, hour > 0 {
                        result += "\(hour) hour\(hour == 1 ? "" : "s")"
                    }
                    return result
                }
                ScrollViewSection(title: "Upcoming") {
                    ScrollViewRow("Episode \(nextEpisode.episode) in \(timeToAiringString) (\(airingDate.toFullString()))")
                }
            }
        }
        .task {
            await load()
        }
    }
}

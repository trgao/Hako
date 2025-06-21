//
//  AnimeProgress.swift
//  Hako
//
//  Created by Gao Tianrun on 19/6/25.
//

import SwiftUI

struct AnimeProgress: View {
    private var numEpisodes: Int?
    private var numEpisodesWatched: Int
    private var status: StatusEnum?
    
    init(numEpisodes: Int?, numEpisodesWatched: Int, status: StatusEnum?) {
        self.numEpisodes = numEpisodes
        self.numEpisodesWatched = numEpisodesWatched
        self.status = status
    }
    
    var body: some View {
        ScrollViewSection(title: "Your progress") {
            VStack {
                if let numEpisodes = numEpisodes, numEpisodes > 0 {
                    ProgressView(value: Float(numEpisodesWatched) / Float(numEpisodes))
                        .tint(status?.toColour())
                    HStack {
                        Text(status?.toString() ?? "")
                            .bold()
                        Spacer()
                        Label("\(String(numEpisodesWatched)) / \(String(numEpisodes))", systemImage: "video.fill")
                            .labelStyle(CustomLabel(spacing: 2))
                    }
                } else {
                    ProgressView(value: numEpisodesWatched == 0 ? 0 : 0.5)
                        .tint(status?.toColour())
                    HStack {
                        Text(status?.toString() ?? "")
                            .bold()
                        Spacer()
                        Label("\(String(numEpisodesWatched)) / ?", systemImage: "video.fill")
                            .labelStyle(CustomLabel(spacing: 2))
                    }
                }
            }
            .padding(20)
        }
    }
}

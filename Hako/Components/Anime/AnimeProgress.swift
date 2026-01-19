//
//  AnimeProgress.swift
//  Hako
//
//  Created by Gao Tianrun on 19/6/25.
//

import SwiftUI

struct AnimeProgress: View {
    private let anime: Anime
    private let numEpisodes: String
    private let numEpisodesWatched: String
    private let watchProgress: Float
    private let isLoading: Bool
    
    init(anime: Anime, isLoading: Bool) {
        self.anime = anime
        self.isLoading = isLoading
        let numEpisodesWatched = anime.myListStatus?.numEpisodesWatched ?? 0
        if let numEpisodes = anime.numEpisodes, numEpisodes > 0 {
            self.numEpisodes = String(numEpisodes)
            self.watchProgress = Float(numEpisodesWatched) / Float(numEpisodes)
        } else {
            self.numEpisodes = "?"
            self.watchProgress = numEpisodesWatched == 0 ? 0 : 0.5
        }
        self.numEpisodesWatched = String(numEpisodesWatched)
    }
    
    var body: some View {
        ScrollViewSection(title: "Progress") {
            VStack {
                if isLoading {
                    ProgressView(value: 0)
                        .skeleton()
                    HStack {
                        Text("Placeholder")
                            .bold()
                        Spacer()
                        Text("0 / 0")
                    }
                    .skeleton()
                } else if let status = anime.myListStatus?.status {
                    ProgressView(value: watchProgress)
                        .tint(status.toColour())
                    HStack {
                        Text(status.toString())
                            .bold()
                        Spacer()
                        Label("\(numEpisodesWatched) / \(numEpisodes)", systemImage: "video.fill")
                            .labelStyle(CustomLabelStyle())
                    }
                } else {
                    ProgressView(value: 0)
                    HStack {
                        Text("Not added")
                            .bold()
                        Spacer()
                        Label("0 / \(numEpisodes)", systemImage: "video.fill")
                            .labelStyle(CustomLabelStyle())
                    }
                }
            }
            .padding(20)
        }
    }
}

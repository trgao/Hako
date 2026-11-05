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
    private let isLoading: Bool
    private let networker = NetworkManager.shared

    private var listStatus: MyListStatus? {
        networker.getAnimeListStatus(anime.id).value
    }

    private var numEpisodesWatched: Int {
        listStatus?.numEpisodesWatched ?? 0
    }

    private var watchProgress: Float {
        if let episodes = anime.numEpisodes, episodes > 0 {
            return Float(numEpisodesWatched) / Float(episodes)
        }
        return numEpisodesWatched == 0 ? 0 : 0.5
    }

    init(anime: Anime, isLoading: Bool) {
        self.anime = anime
        self.isLoading = isLoading
        if let numEpisodes = anime.numEpisodes, numEpisodes > 0 {
            self.numEpisodes = String(numEpisodes)
        } else {
            self.numEpisodes = "?"
        }
    }

    var body: some View {
        ScrollViewSection(title: "Progress") {
            VStack {
                if isLoading {
                    HStack {
                        Text("Placeholder")
                            .bold()
                        Spacer()
                        Text("0 / 0")
                    }
                    .skeleton()
                    ProgressView(value: 0)
                        .skeleton()
                } else if let status = listStatus?.status {
                    HStack {
                        Text(status.toString())
                            .foregroundStyle(status.toColour())
                            .bold()
                        Spacer()
                        Label("\(numEpisodesWatched) / \(numEpisodes)", systemImage: "video.fill")
                            .labelStyle(.reducedSpace)
                    }
                    ProgressView(value: watchProgress)
                        .tint(status.toColour())
                } else {
                    HStack {
                        Text("Not added")
                            .bold()
                        Spacer()
                        Label("0 / \(numEpisodes)", systemImage: "video.fill")
                            .labelStyle(.reducedSpace)
                    }
                    ProgressView(value: 0)
                }
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
        }
    }
}

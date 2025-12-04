//
//  AnimeProgress.swift
//  Hako
//
//  Created by Gao Tianrun on 19/6/25.
//

import SwiftUI
import Shimmer

struct AnimeProgress: View {
    private let numEpisodes: String
    private let numEpisodesWatched: String
    private let watchProgress: Float
    private let status: StatusEnum?
    
    init(numEpisodes: Int?, numEpisodesWatched: Int, status: StatusEnum?) {
        if let numEpisodes = numEpisodes, numEpisodes > 0 {
            self.numEpisodes = String(numEpisodes)
            self.watchProgress = Float(numEpisodesWatched) / Float(numEpisodes)
        } else {
            self.numEpisodes = "?"
            self.watchProgress = numEpisodesWatched == 0 ? 0 : 0.5
        }
        self.numEpisodesWatched = String(numEpisodesWatched)
        self.status = status
    }
    
    var body: some View {
        ScrollViewSection(title: "Progress") {
            VStack {
                ProgressView(value: watchProgress)
                    .tint(status?.toColour())
                HStack {
                    Text(status?.toString() ?? "")
                        .bold()
                    Spacer()
                    Label("\(numEpisodesWatched) / \(numEpisodes)", systemImage: "video.fill")
                        .labelStyle(CustomLabel(spacing: 2))
                }
            }
            .padding(20)
        }
    }
}

struct AnimeProgressNotAdded: View {
    private let numEpisodes: String
    private let isLoading: Bool
    
    init(numEpisodes: Int?, isLoading: Bool) {
        if let numEpisodes = numEpisodes, numEpisodes > 0 {
            self.numEpisodes = String(numEpisodes)
        } else {
            self.numEpisodes = "?"
        }
        self.isLoading = isLoading
    }
    
    var body: some View {
        ScrollViewSection(title: "Progress") {
            VStack {
                if isLoading {
                    ProgressView(value: 0)
                        .redacted(reason: .placeholder)
                        .shimmering()
                    HStack {
                        Text("Placeholder")
                            .bold()
                        Spacer()
                        Label("0 / 0", systemImage: "video.fill")
                            .labelStyle(CustomLabel(spacing: 2))
                    }
                    .redacted(reason: .placeholder)
                    .shimmering()
                } else {
                    ProgressView(value: 0)
                    HStack {
                        Text("Not added")
                            .bold()
                        Spacer()
                        Label("0 / \(numEpisodes)", systemImage: "video.fill")
                            .labelStyle(CustomLabel(spacing: 2))
                    }
                }
            }
            .padding(20)
        }
    }
}

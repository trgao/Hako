//
//  Episodes.swift
//  Hako
//
//  Created by Gao Tianrun on 7/7/26.
//

import SwiftUI

struct Episodes: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.screenSize) private var screenSize
    @EnvironmentObject private var settings: SettingsManager
    @State private var episodesPreview: [Episode] = []
    private let id: Int
    private let episodes: [Episode]?
    private let loadingState: LoadingEnum
    private let load: () async -> Void
    
    init(id: Int, episodes: [Episode]?, loadingState: LoadingEnum, load: @escaping () async -> Void) {
        self.id = id
        self.episodes = episodes
        self.loadingState = loadingState
        self.load = load
    }
    
    var body: some View {
        ScrollViewCarousel(title: "Episodes", count: episodes?.count, viewAlignedScroll: screenSize.width - 34 < 450, loadingState: loadingState, refresh: load) { isLoading in
            PlaceholderEpisode(isLoading: isLoading)
        } content: {
            ForEach(episodesPreview) { item in
                EpisodeItem(item: item)
            }
        } destination: {
            EpisodesListView(id: id)
        }
        .task {
            await load()
            episodesPreview = Array(episodes?.prefix(10) ?? [])
        }
        .onChange(of: episodes?.count) {
            episodesPreview = Array(episodes?.prefix(10) ?? [])
        }
    }
}

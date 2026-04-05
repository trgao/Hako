//
//  AnimeListItem.swift
//  Hako
//
//  Created by Gao Tianrun on 15/5/24.
//

import SwiftUI

struct AnimeListItem: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var networker = NetworkManager.shared
    @Binding private var selectedAnime: MALListAnime?
    @Binding private var selectedAnimeIndex: Int?
    private let anime: MALListAnime
    private let index: Int
    private let numEpisodes: String
    private let numEpisodesWatched: String
    private let watchProgress: Float
    private let isLoading: Bool
    private var title: String {
        settings.getTitle(romaji: anime.node.title, english: anime.node.alternativeTitles?.en, native: anime.node.alternativeTitles?.ja)
    }
    
    init(anime: MALListAnime, selectedAnime: Binding<MALListAnime?> = Binding.constant(nil), selectedAnimeIndex: Binding<Int?> = Binding.constant(nil), index: Int = -1, isLoading: Bool = false) {
        self.anime = anime
        self._selectedAnime = selectedAnime
        self._selectedAnimeIndex = selectedAnimeIndex
        self.index = index
        let watched = anime.listStatus?.numEpisodesWatched ?? 0
        if let episodes = anime.node.numEpisodes, episodes > 0 {
            self.numEpisodes = String(episodes)
            self.watchProgress = Float(watched) / Float(episodes)
        } else {
            self.numEpisodes = "?"
            self.watchProgress = watched == 0 ? 0 : 0.5
        }
        self.numEpisodesWatched = String(watched)
        self.isLoading = isLoading
    }
    
    var body: some View {
        NavigationLink {
            AnimeDetailsView(anime: anime.node)
        } label: {
            HStack {
                ImageFrame(id: "anime\(anime.id)", imageUrl: anime.node.mainPicture?.large, imageSize: Constants.listImageSize)
                VStack(alignment: .leading) {
                    Text(title)
                        .lineLimit(settings.getLineLimit())
                        .bold()
                    HStack(alignment: .center) {
                        VStack(alignment: .leading) {
                            if let startSeason = anime.node.startSeason, let season = startSeason.season, let year = startSeason.year {
                                Text("\(season.rawValue.capitalized), \(String(year))")
                            }
                            if let status = anime.node.status {
                                Text(status.formatStatus())
                            }
                            HStack {
                                Text("\(anime.node.mean == nil ? "N/A" : String(anime.node.mean!)) ⭐")
                                if let score = anime.listStatus?.score, score > 0 {
                                    Label("\(score) ⭐", systemImage: "person.fill")
                                        .labelStyle(.reducedSpace)
                                }
                            }
                            .bold()
                        }
                        .opacity(0.7)
                        .font(.footnote)
                        Spacer()
                        if networker.isSignedIn && index != -1 {
                            Button {
                                selectedAnime = anime
                                selectedAnimeIndex = index
                            } label: {
                                Image(systemName: "square.and.pencil")
                            }
                            .buttonStyle(.bordered)
                            .disabled(isLoading)
                        }
                    }
                    if networker.isSignedIn || anime.listStatus != nil {
                        VStack(alignment: .leading) {
                            ProgressView(value: watchProgress)
                                .tint(anime.listStatus?.status?.toColour())
                            Label("\(numEpisodesWatched) / \(numEpisodes)", systemImage: "video.fill")
                                .foregroundStyle(Color(.systemGray))
                                .labelStyle(.reducedSpace)
                                .font(.caption)
                        }
                        .padding(.top, 5)
                    }
                }
                .padding(.horizontal, 5)
            }
            .contextMenu {
                ShareLink(item: URL(string: "https://myanimelist.net/anime/\(anime.id)")!) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
        .padding(5)
    }
}

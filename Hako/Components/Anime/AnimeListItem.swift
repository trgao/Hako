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
    
    
    init(anime: MALListAnime, selectedAnime: Binding<MALListAnime?> = Binding.constant(nil), selectedAnimeIndex: Binding<Int?> = Binding.constant(nil), index: Int = -1) {
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
    }
    
    var body: some View {
        NavigationLink {
            AnimeDetailsView(anime: anime.node)
        } label: {
            HStack {
                ImageFrame(id: "anime\(anime.id)", imageUrl: anime.node.mainPicture?.large, imageSize: Constants.listImageSize)
                VStack(alignment: .leading) {
                    if let title = anime.node.alternativeTitles?.en, !title.isEmpty && settings.preferredTitleLanguage == 1 {
                        Text(title)
                            .lineLimit(settings.getLineLimit())
                            .bold()
                            .font(.callout)
                    } else {
                        Text(anime.node.title)
                            .lineLimit(settings.getLineLimit())
                            .bold()
                            .font(.callout)
                    }
                    if let listStatus = anime.listStatus {
                        VStack(alignment: .leading) {
                            ProgressView(value: watchProgress)
                                .tint(listStatus.status?.toColour())
                            HStack {
                                Label("\(numEpisodesWatched) / \(numEpisodes)", systemImage: "video.fill")
                                    .foregroundStyle(Color(.systemGray))
                                    .labelStyle(CustomLabel(spacing: 2))
                                Spacer()
                                if listStatus.score > 0 {
                                    Text("\(listStatus.score) ⭐")
                                        .bold()
                                }
                            }
                            .font(.footnote)
                        }
                    }
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            if let startSeason = anime.node.startSeason, let season = startSeason.season, let year = startSeason.year {
                                Text("\(season.rawValue.capitalized), \(String(year))")
                            }
                            if let status = anime.node.status {
                                Text(status.formatStatus())
                            }
                        }
                        .opacity(0.7)
                        .font(.footnote)
                        .padding(.top, 1)
                        Spacer()
                        if networker.isSignedIn && index != -1 {
                            Button {
                                selectedAnime = anime
                                selectedAnimeIndex = index
                            } label: {
                                Image(systemName: "square.and.pencil")
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                .padding(5)
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

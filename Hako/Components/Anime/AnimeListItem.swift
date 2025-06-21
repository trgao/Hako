//
//  AnimeListItem.swift
//  Hako
//
//  Created by Gao Tianrun on 15/5/24.
//

import SwiftUI

struct AnimeListItem: View {
    @EnvironmentObject private var settings: SettingsManager
    @Binding private var selectedAnime: MALListAnime?
    @Binding private var selectedAnimeIndex: Int?
    private let anime: MALListAnime
    private let index: Int
    let networker = NetworkManager.shared
    
    init(anime: MALListAnime) {
        self.anime = anime
        self._selectedAnime = .constant(nil)
        self._selectedAnimeIndex = .constant(nil)
        self.index = 0
    }
    
    init(anime: MALListAnime, status: StatusEnum, selectedAnime: Binding<MALListAnime?>, selectedAnimeIndex: Binding<Int?>, index: Int) {
        self.anime = anime
        self._selectedAnime = selectedAnime
        self._selectedAnimeIndex = selectedAnimeIndex
        self.index = index
    }
    
    var body: some View {
        NavigationLink {
            AnimeDetailsView(id: anime.id)
        } label: {
            HStack {
                ImageFrame(id: "anime\(anime.id)", imageUrl: anime.node.mainPicture?.large, imageSize: .small)
                VStack(alignment: .leading) {
                    if let title = anime.node.alternativeTitles?.en, !title.isEmpty && settings.preferredTitleLanguage == 1 {
                        Text(title)
                            .lineLimit(settings.getLineLimit())
                            .bold()
                            .font(.system(size: 16))
                    } else {
                        Text(anime.node.title)
                            .lineLimit(settings.getLineLimit())
                            .bold()
                            .font(.system(size: 16))
                    }
                    if let numEpisodesWatched = anime.listStatus?.numEpisodesWatched {
                        if let numEpisodes = anime.node.numEpisodes, numEpisodes > 0 {
                            VStack(alignment: .leading) {
                                ProgressView(value: Float(numEpisodesWatched) / Float(numEpisodes))
                                    .tint(anime.listStatus?.status?.toColour())
                                HStack {
                                    Label("\(String(numEpisodesWatched)) / \(String(numEpisodes))", systemImage: "video.fill")
                                        .foregroundStyle(Color(.systemGray))
                                        .labelStyle(CustomLabel(spacing: 2))
                                    Spacer()
                                    if let score = anime.listStatus?.score, score > 0 {
                                        Text("\(score) ⭐")
                                            .bold()
                                    }
                                }
                                .font(.system(size: 13))
                            }
                        } else {
                            VStack(alignment: .leading) {
                                ProgressView(value: numEpisodesWatched == 0 ? 0 : 0.5)
                                    .tint(anime.listStatus?.status?.toColour())
                                HStack {
                                    Label("\(String(numEpisodesWatched)) / ?", systemImage: "video.fill")
                                        .foregroundStyle(Color(.systemGray))
                                        .labelStyle(CustomLabel(spacing: 2))
                                    Spacer()
                                    if let score = anime.listStatus?.score, score > 0 {
                                        Text("\(score) ⭐")
                                            .bold()
                                    }
                                }
                            }
                            .font(.system(size: 13))
                        }
                    }
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            if let startSeason = anime.node.startSeason, let season = startSeason.season, let year = startSeason.year {
                                Text("\(season.capitalized), \(String(year))")
                            }
                            if let status = anime.node.status {
                                Text(status.formatStatus())
                            }
                        }
                        .opacity(0.7)
                        .font(.system(size: 13))
                        .padding(.top, 1)
                        Spacer()
                        if networker.isSignedIn && anime.listStatus != nil {
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
        }
        .padding(5)
    }
}

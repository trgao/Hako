//
//  AnimeListItem.swift
//  Hako
//
//  Created by Gao Tianrun on 15/5/24.
//

import SwiftUI

struct AnimeListItem: View {
    @EnvironmentObject private var settings: SettingsManager
    @ObservedObject private var networker = NetworkManager.shared
    @Binding private var selectedAnime: MALListAnime?
    private let anime: MALListAnime
    private let numEpisodes: String
    private let isLoading: Bool
    private let isOtherUser: Bool

    private var title: String {
        settings.getTitle(romaji: anime.node.title, english: anime.node.alternativeTitles?.en, native: anime.node.alternativeTitles?.ja)
    }

    private var listStatus: MyListStatus? {
        isOtherUser ? anime.listStatus : networker.getAnimeListStatus(anime.id).value
    }

    private var numEpisodesWatched: Int {
        listStatus?.numEpisodesWatched ?? 0
    }

    private var watchProgress: Float {
        if let episodes = anime.node.numEpisodes, episodes > 0 {
            return Float(numEpisodesWatched) / Float(episodes)
        }
        return numEpisodesWatched == 0 ? 0 : 0.5
    }

    init(anime: MALListAnime, isLoading: Bool = false, isOtherUser: Bool = false, selectedAnime: Binding<MALListAnime?> = .constant(nil)) {
        self.anime = anime
        self.isLoading = isLoading
        self.isOtherUser = isOtherUser
        self._selectedAnime = selectedAnime

        if let episodes = anime.node.numEpisodes, episodes > 0 {
            self.numEpisodes = String(episodes)
        } else {
            self.numEpisodes = "?"
        }
    }

    var body: some View {
        NavigationLink(value: Route.animeItem(anime)) {
            HStack {
                ImageFrame(id: "anime\(anime.id)", imageUrl: anime.node.mainPicture?.large, imageSize: Constants.listImageSize)
                VStack(alignment: .leading) {
                    Text(title)
                        .lineLimit(settings.getLineLimit())
                        .bold()
                        .foregroundStyle(Color.primary)
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
                                if let score = listStatus?.score, score > 0 {
                                    Label("\(score) ⭐", systemImage: "person.fill")
                                        .labelStyle(.reducedSpace)
                                }
                            }
                            .bold()
                        }
                        .opacity(0.7)
                        .font(.footnote)
                        .foregroundStyle(Color.primary)
                        Spacer()
                        if networker.isSignedIn && !isOtherUser {
                            Button {
                                selectedAnime = anime
                            } label: {
                                Image(systemName: "square.and.pencil")
                            }
                            .buttonStyle(.bordered)
                            .disabled(isLoading)
                        }
                    }
                    if networker.isSignedIn || listStatus != nil {
                        VStack(alignment: .leading) {
                            ProgressView(value: watchProgress)
                                .tint(listStatus?.status?.toColour())
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

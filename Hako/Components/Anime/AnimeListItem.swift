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
    private let refresh: () async -> Void
    private let colours: [StatusEnum:Color] = [
        .watching: Color(.systemGreen),
        .completed: Color(.systemBlue),
        .onHold: Color(.systemYellow),
        .dropped: Color(.systemRed),
        .planToWatch: .primary,
        .none: Color(.systemGray)
    ]
    let networker = NetworkManager.shared
    
    init(anime: MALListAnime) {
        self.anime = anime
        self._selectedAnime = .constant(nil)
        self._selectedAnimeIndex = .constant(nil)
        self.index = 0
        self.refresh = {}
    }
    
    init(anime: MALListAnime, status: StatusEnum, selectedAnime: Binding<MALListAnime?>, selectedAnimeIndex: Binding<Int?>, index: Int, refresh: @escaping () async -> Void) {
        self.anime = anime
        self._selectedAnime = selectedAnime
        self._selectedAnimeIndex = selectedAnimeIndex
        self.index = index
        self.refresh = refresh
    }
    
    var body: some View {
        NavigationLink {
            AnimeDetailsView(id: anime.id)
                .onDisappear {
                    Task {
                        await refresh()
                    }
                }
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
                                    .tint(colours[anime.listStatus?.status ?? .none])
                                Label("\(String(numEpisodesWatched)) / \(String(numEpisodes))", systemImage: "video.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color(.systemGray))
                                    .labelStyle(CustomLabel(spacing: 2))
                            }
                        } else {
                            VStack(alignment: .leading) {
                                ProgressView(value: numEpisodesWatched == 0 ? 0 : 0.5)
                                    .tint(colours[anime.listStatus?.status ?? .none])
                                Label("\(String(numEpisodesWatched)) / ?", systemImage: "video.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color(.systemGray))
                                    .labelStyle(CustomLabel(spacing: 2))
                            }
                        }
                    }
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(anime.node.status?.formatStatus() ?? "")
                                .opacity(0.7)
                                .font(.system(size: 12))
                            if let score = anime.listStatus?.score, score > 0 {
                                Text("\(score) ⭐")
                                    .bold()
                                    .font(.system(size: 13))
                            }
                        }
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

//
//  AnimeListItem.swift
//  MALC
//
//  Created by Gao Tianrun on 15/5/24.
//

import SwiftUI

struct AnimeListItem: View {
    @State private var isEditViewPresented = false
    @Binding private var isBack: Bool
    private let anime: MALListAnime
    private let status: StatusEnum
    private let colours: [StatusEnum:Color] = [
        .watching: Color(.systemGreen),
        .completed: Color(.systemBlue),
        .onHold: Color(.systemYellow),
        .dropped: Color(.systemRed),
        .planToWatch: Color(.systemGray),
        .none: Color(.systemBlue)
    ]
    private let refresh: () async -> Void
    let networker = NetworkManager.shared
    
    init(anime: MALListAnime) {
        self.anime = anime
        self.status = .none
        self.refresh = {}
        self._isBack = .constant(false)
    }
    
    init(anime: MALListAnime, status: StatusEnum, refresh: @escaping () async -> Void, isBack: Binding<Bool>) {
        self.anime = anime
        self.status = status
        self.refresh = refresh
        self._isBack = isBack
    }
    
    var body: some View {
        NavigationLink {
            AnimeDetailsView(id: anime.id)
                .onAppear {
                    isBack = false
                }
                .onDisappear {
                    isBack = true
                }
        } label: {
            HStack {
                ImageFrame(id: "anime\(anime.id)", width: 75, height: 106)
                VStack(alignment: .leading) {
                    Text(anime.node.title)
                        .bold()
                        .font(.system(size: 16))
                    if let numEpisodesWatched = anime.listStatus?.numEpisodesWatched {
                        if let numEpisodes = anime.node.numEpisodes, numEpisodes > 0 {
                            VStack(alignment: .leading) {
                                ProgressView(value: Float(numEpisodesWatched) / Float(numEpisodes))
                                    .tint(colours[status])
                                Label("\(String(numEpisodesWatched)) / \(String(numEpisodes))", systemImage: "video.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color(.systemGray))
                                    .labelStyle(CustomLabel(spacing: 1))
                            }
                        } else {
                            VStack(alignment: .leading) {
                                ProgressView(value: numEpisodesWatched == 0 ? 0 : 0.5)
                                    .tint(colours[status])
                                Label("\(String(numEpisodesWatched)) / ?", systemImage: "video.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color(.systemGray))
                                    .labelStyle(CustomLabel(spacing: 1))
                            }
                        }
                    }
                    HStack {
                        if let score = anime.listStatus?.score, score > 0 {
                            Text("\(score) ⭐")
                                .bold()
                                .font(.system(size: 13))
                                .padding(.top, 3)
                        }
                        Spacer()
                        if networker.isSignedIn && anime.listStatus != nil {
                            Button {
                                isEditViewPresented = true
                            } label: {
                                Image(systemName: "square.and.pencil")
                            }
                            .buttonStyle(BorderedButtonStyle())
                            .foregroundStyle(Color(.systemBlue))
                            .sheet(isPresented: $isEditViewPresented) {
                                Task {
                                    await refresh()
                                }
                            } content: {
                                AnimeEditView(id: anime.id, listStatus: anime.listStatus, title: anime.node.title, numEpisodes: anime.node.numEpisodes!, isPresented: $isEditViewPresented)
                            }
                        }
                    }
                }
                .padding(5)
            }
        }
        .buttonStyle(.plain)
        .padding(5)
    }
}

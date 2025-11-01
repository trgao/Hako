//
//  TopView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

struct TopView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller = TopViewController()
    @State private var isInit = false
    @State private var offset: CGFloat = -18
    @State private var isRefresh = false
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150), alignment: .top),
    ]
    let networker = NetworkManager.shared
    
    // Display medals instead of numbers for the first 3 ranks
    private func rankToString(_ rank: Int?) -> String {
        if rank == nil {
            return ""
        }
        let ranks = ["🥇", "🥈", "🥉"]
        if rank! <= 3 {
            return ranks[rank! - 1]
        } else {
            return String(rank!)
        }
    }
    
    var filter: some View {
        Menu {
            if controller.type == .anime {
                Picker(selection: $controller.animeRankingType, label: Text("Rank type")) {
                    Label("All", systemImage: "star").tag("all")
                    Label("TV", systemImage: "tv").tag("tv")
                    Label("OVA", systemImage: "tv").tag("ova")
                    Label("Movie", systemImage: "movieclapper").tag("movie")
                    Label("Special", systemImage: "sparkles.tv").tag("special")
                    Label("Popularity", systemImage: "popcorn").tag("bypopularity")
                    Label("Favourites", systemImage: "heart").tag("favorite")
                }
            } else if controller.type == .manga {
                Picker(selection: $controller.mangaRankingType, label: Text("Rank type")) {
                    Label("All", systemImage: "star").tag("all")
                    Label("Manga", systemImage: "book").tag("manga")
                    Label("Novels", systemImage: "book.closed").tag("novels")
                    Label("Oneshots", systemImage: "book.pages").tag("oneshots")
                    Label("Manhwa", systemImage: "book").tag("manhwa")
                    Label("Manhua", systemImage: "book").tag("manhua")
                    Label("Popularity", systemImage: "popcorn").tag("bypopularity")
                    Label("Favourites", systemImage: "heart").tag("favorite")
                }
            }
        } label: {
            Button{} label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
            }
        }
        .onChange(of: controller.animeRankingType) {
            Task {
                await controller.refreshAnime()
            }
        }
        .onChange(of: controller.mangaRankingType) {
            Task {
                await controller.refreshManga()
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if controller.type == .anime {
                    ZStack {
                        ScrollView {
                            if controller.isAnimeLoadingError && controller.animeItems.isEmpty {
                                ErrorView(refresh: { await controller.refreshAnime() })
                            } else {
                                VStack {
                                    if controller.animeRankingType != "all" {
                                        Text(controller.animeRankingType.formatRankingType())
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 20)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(Color(.systemGray))
                                            .bold()
                                    }
                                    LazyVGrid(columns: columns) {
                                        ForEach(Array(controller.animeItems.enumerated()), id: \.1.node.id) { index, item in
                                            AnimeGridItem(id: item.node.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large, subtitle: rankToString(item.ranking?.rank), anime: item.node)
                                                .task {
                                                    await controller.loadMoreIfNeeded(index: index)
                                                }
                                        }
                                    }
                                }
                                .padding(10)
                            }
                        }
                        if controller.isAnimeLoading {
                            LoadingView()
                        }
                        if controller.animeItems.isEmpty && !controller.isAnimeLoading && !controller.isAnimeLoadingError {
                            VStack {
                                Image(systemName: "medal")
                                    .resizable()
                                    .frame(width: 40, height: 50)
                                Text("Nothing found")
                                    .bold()
                            }
                        }
                    }
                } else if controller.type == .manga {
                    ZStack {
                        ScrollView {
                            if controller.isMangaLoadingError && controller.mangaItems.isEmpty {
                                ErrorView(refresh: { await controller.refreshManga() })
                            } else {
                                VStack {
                                    if controller.mangaRankingType != "all" {
                                        Text(controller.mangaRankingType.formatRankingType())
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 20)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(Color(.systemGray))
                                            .bold()
                                    }
                                    LazyVGrid(columns: columns) {
                                        ForEach(Array(controller.mangaItems.enumerated()), id: \.1.node.id) { index, item in
                                            MangaGridItem(id: item.node.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large, subtitle: rankToString(item.ranking?.rank), manga: item.node)
                                                .task {
                                                    await controller.loadMoreIfNeeded(index: index)
                                                }
                                        }
                                    }
                                }
                                .padding(10)
                            }
                        }
                        if controller.isMangaLoading {
                            LoadingView()
                        }
                        if controller.mangaItems.isEmpty && !controller.isMangaLoading && !controller.isMangaLoadingError {
                            VStack {
                                Image(systemName: "medal")
                                    .resizable()
                                    .frame(width: 40, height: 50)
                                Text("Nothing found")
                                    .bold()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Top \(controller.type.toString())")
            .task(id: isRefresh) {
                if controller.shouldRefresh() || isRefresh {
                    await controller.refresh(true)
                    isRefresh = false
                }
            }
            .refreshable {
                isRefresh = true
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    filter
                        .disabled(controller.isLoading())
                }
                ToolbarItem(placement: .topBarTrailing) {
                    AnimeMangaToggle(type: $controller.type)
                }
            }
        }
        .onAppear {
            if !isInit {
                controller.animeRankingType = settings.getAnimeRanking()
                controller.mangaRankingType = settings.getMangaRanking()
                isInit = true
            }
        }
    }
}

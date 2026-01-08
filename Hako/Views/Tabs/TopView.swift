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
    @Binding private var id: UUID
    @Binding private var type: TypeEnum?
    @Binding private var animeRanking: RankingEnum?
    @Binding private var mangaRanking: RankingEnum?
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150), alignment: .top),
    ]
    let networker = NetworkManager.shared
    
    init(id: Binding<UUID>, type: Binding<TypeEnum?>, animeRanking: Binding<RankingEnum?>, mangaRanking: Binding<RankingEnum?>) {
        self._id = id
        self._type = type
        self._animeRanking = animeRanking
        self._mangaRanking = mangaRanking
    }
    
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
    
    private var filter: some View {
        Menu {
            if controller.type == .anime {
                Picker(selection: $controller.animeRankingType, label: Text("Rank type")) {
                    Label("All", systemImage: "star").tag(RankingEnum.all)
                    Label("TV", systemImage: "tv").tag(RankingEnum.tv)
                    Label("OVA", systemImage: "tv").tag(RankingEnum.ova)
                    Label("Movie", systemImage: "movieclapper").tag(RankingEnum.movie)
                    Label("Special", systemImage: "sparkles.tv").tag(RankingEnum.special)
                    Label("Popularity", systemImage: "popcorn").tag(RankingEnum.bypopularity)
                    Label("Favourites", systemImage: "heart").tag(RankingEnum.favorite)
                }
            } else if controller.type == .manga {
                Picker(selection: $controller.mangaRankingType, label: Text("Rank type")) {
                    Label("All", systemImage: "star").tag(RankingEnum.all)
                    Label("Manga", systemImage: "book").tag(RankingEnum.manga)
                    Label("Novels", systemImage: "book.closed").tag(RankingEnum.novels)
                    Label("Oneshots", systemImage: "book.pages").tag(RankingEnum.oneshots)
                    Label("Manhwa", systemImage: "book").tag(RankingEnum.manhwa)
                    Label("Manhua", systemImage: "book").tag(RankingEnum.manhua)
                    Label("Popularity", systemImage: "popcorn").tag(RankingEnum.bypopularity)
                    Label("Favourites", systemImage: "heart").tag(RankingEnum.favorite)
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
                                    if controller.animeRankingType != .all {
                                        Text(controller.animeRankingType.toString())
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
                                    if controller.mangaRankingType != .all {
                                        Text(controller.mangaRankingType.toString())
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
            .navigationTitle("Top \(controller.type.rawValue)")
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
        .id(id)
        .task(id: id) {
            if let type = type {
                controller.type = type
            }
            type = nil
            if controller.type == .anime {
                if let animeRanking = animeRanking {
                    controller.animeRankingType = animeRanking
                }
                animeRanking = nil
            } else if controller.type == .manga {
                if let mangaRanking = mangaRanking {
                    controller.mangaRankingType = mangaRanking
                }
                mangaRanking = nil
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

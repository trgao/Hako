//
//  TopView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

struct TopView: View {
    @Environment(\.screenRatio) private var screenRatio
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller = TopViewController()
    @State private var isInit = false
    @State private var isRefresh = false
    @Binding private var id: UUID
    @Binding private var type: TypeEnum?
    @Binding private var animeRanking: RankingEnum?
    @Binding private var mangaRanking: RankingEnum?
    let networker = NetworkManager.shared
    
    init(id: Binding<UUID>, type: Binding<TypeEnum?>, animeRanking: Binding<RankingEnum?>, mangaRanking: Binding<RankingEnum?>) {
        self._id = id
        self._type = type
        self._animeRanking = animeRanking
        self._mangaRanking = mangaRanking
    }
    
    // Display medals instead of numbers for the first 3 ranks
    private func rankToString(_ rank: Int?) -> String {
        guard let rank = rank else {
            return ""
        }
        if rank <= 3 {
            return Constants.ranks[rank - 1]
        } else {
            return String(rank)
        }
    }
    
    private var filter: some View {
        Menu {
            if controller.type == .anime {
                Picker("Rank type", selection: $controller.animeRankingType) {
                    Label("All", systemImage: "star").tag(RankingEnum.all)
                    Label("TV", systemImage: "tv").tag(RankingEnum.tv)
                    Label("OVA", systemImage: "tv").tag(RankingEnum.ova)
                    Label("Movie", systemImage: "movieclapper").tag(RankingEnum.movie)
                    Label("Special", systemImage: "sparkles.tv").tag(RankingEnum.special)
                    Label("Popularity", systemImage: "popcorn").tag(RankingEnum.bypopularity)
                    Label("Favourites", systemImage: "heart").tag(RankingEnum.favorite)
                }
                .pickerStyle(.inline)
            } else if controller.type == .manga {
                Picker("Rank type", selection: $controller.mangaRankingType) {
                    Label("All", systemImage: "star").tag(RankingEnum.all)
                    Label("Manga", systemImage: "book").tag(RankingEnum.manga)
                    Label("Light Novels", systemImage: "book.closed").tag(RankingEnum.lightnovels)
                    Label("Novels", systemImage: "book.closed").tag(RankingEnum.novels)
                    Label("Oneshots", systemImage: "book.pages").tag(RankingEnum.oneshots)
                    Label("Manhwa", systemImage: "book").tag(RankingEnum.manhwa)
                    Label("Manhua", systemImage: "book").tag(RankingEnum.manhua)
                    Label("Popularity", systemImage: "popcorn").tag(RankingEnum.bypopularity)
                    Label("Favourites", systemImage: "heart").tag(RankingEnum.favorite)
                }
                .pickerStyle(.inline)
            }
        } label: {
            Label("Menu", systemImage: "line.3.horizontal.decrease.circle")
                .labelStyle(.iconOnly)
        }
        .onChange(of: controller.animeRankingType) {
            if isInit {
                Task {
                    await controller.refresh(true)
                }
            }
        }
        .onChange(of: controller.mangaRankingType) {
            if isInit {
                Task {
                    await controller.refresh(true)
                }
            }
        }
    }
    
    private var animeRankingText: some View {
        Text(controller.animeRankingType.toString())
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color(.systemGray))
            .bold()
    }
    
    private var mangaRankingText: some View {
        Text(controller.mangaRankingType.toString())
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color(.systemGray))
            .bold()
    }
    
    private var nothingFoundView: some View {
        VStack {
            Image(systemName: "medal")
                .resizable()
                .frame(width: 40, height: 50)
            Text("Nothing found")
                .bold()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if controller.type == .anime {
                    if controller.animeItems.isEmpty {
                        VStack {
                            if controller.animeRankingType != .all {
                                animeRankingText
                            }
                            if controller.loadingState == .error {
                                ErrorView(refresh: { await controller.refresh() })
                            } else if controller.loadingState == .idle {
                                nothingFoundView
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    } else {
                        ScrollView {
                            if controller.animeRankingType != .all {
                                animeRankingText
                            }
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150 * screenRatio), spacing: 5, alignment: .top)]) {
                                ForEach(Array(controller.animeItems.enumerated()), id: \.1.node.id) { index, item in
                                    AnimeGridItem(id: item.node.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large, subtitle: rankToString(item.ranking?.rank), anime: item.node)
                                        .onAppear {
                                            Task {
                                                await controller.loadMoreIfNeeded(index: index)
                                            }
                                        }
                                }
                            }
                            .padding(10)
                        }
                    }
                } else if controller.type == .manga {
                    if controller.mangaItems.isEmpty {
                        VStack {
                            if controller.mangaRankingType != .all {
                                mangaRankingText
                            }
                            if controller.loadingState == .error {
                                ErrorView(refresh: { await controller.refresh() })
                            } else if controller.loadingState == .idle {
                                nothingFoundView
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    } else {
                        ScrollView {
                            if controller.mangaRankingType != .all {
                                mangaRankingText
                            }
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150 * screenRatio), spacing: 5, alignment: .top)]) {
                                ForEach(Array(controller.mangaItems.enumerated()), id: \.1.node.id) { index, item in
                                    MangaGridItem(id: item.node.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large, subtitle: rankToString(item.ranking?.rank), manga: item.node)
                                        .onAppear {
                                            Task {
                                                await controller.loadMoreIfNeeded(index: index)
                                            }
                                        }
                                }
                            }
                            .padding(10)
                        }
                    }
                }
                if controller.isLoading() {
                    LoadingView()
                }
            }
            .navigationTitle("Top \(controller.type.rawValue)")
            .refreshable {
                isRefresh = true
            }
            .task(id: isRefresh) {
                if controller.isItemsEmpty() || isRefresh {
                    await controller.refresh()
                    isRefresh = false
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    filter
                        .disabled(controller.isLoading())
                }
                ToolbarItem(placement: .topBarTrailing) {
                    AnimeMangaToggle(type: $controller.type, isLoading: controller.isLoading())
                        .onChange(of: controller.type) {
                            if controller.isItemsEmpty() {
                                Task {
                                    await controller.refresh()
                                }
                            }
                        }
                }
            }
        }
        .id(id)
        .task(id: id) {
            if let type = type {
                controller.type = type
            }
            if controller.type == .anime, let animeRanking = animeRanking {
                controller.animeRankingType = animeRanking
            } else if controller.type == .manga, let mangaRanking = mangaRanking {
                controller.mangaRankingType = mangaRanking
            } else if !isInit {
                controller.animeRankingType = settings.getAnimeRanking()
                controller.mangaRankingType = settings.getMangaRanking()
            }
            type = nil
            animeRanking = nil
            mangaRanking = nil
            isInit = true
        }
    }
}

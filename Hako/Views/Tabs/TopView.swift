//
//  TopView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

struct TopView: View {
    @StateObject private var controller = TopViewController()
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150), alignment: .top),
    ]
    @State private var offset: CGFloat = -18
    @State private var isRefresh = false
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
    
    var body: some View {
        NavigationStack {
            VStack {
                if controller.type == .anime {
                    ZStack {
                        ScrollView {
                            if controller.isLoadingError && controller.animeItems.isEmpty {
                                ErrorView(refresh: controller.refresh)
                            } else {
                                LazyVGrid(columns: columns) {
                                    ForEach(Array(controller.animeItems.enumerated()), id: \.1.node.id) { index, item in
                                        AnimeGridItem(id: item.node.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large, subtitle: rankToString(item.ranking?.rank))
                                            .task {
                                                await controller.loadMoreIfNeeded(index: index)
                                            }
                                    }
                                }
                                .padding(10)
                            }
                        }
                        if controller.isAnimeLoading {
                            LoadingView()
                        }
                        if controller.isItemsEmpty() && !controller.isAnimeLoading && !controller.isLoadingError {
                            VStack {
                                Image(systemName: "medal")
                                    .resizable()
                                    .frame(width: 40, height: 50)
                                Text("Nothing found")
                                    .bold()
                            }
                        }
                    }
                    .navigationTitle("Top Anime")
                } else if controller.type == .manga {
                    ZStack {
                        ScrollView {
                            if controller.isLoadingError && controller.mangaItems.isEmpty {
                                ErrorView(refresh: controller.refresh)
                            } else {
                                LazyVGrid(columns: columns) {
                                    ForEach(Array(controller.mangaItems.enumerated()), id: \.1.node.id) { index, item in
                                        MangaGridItem(id: item.node.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large, subtitle: rankToString(item.ranking?.rank))
                                            .task {
                                                await controller.loadMoreIfNeeded(index: index)
                                            }
                                    }
                                }
                                .padding(10)
                            }
                        }
                        if controller.isMangaLoading {
                            LoadingView()
                        }
                        if controller.isItemsEmpty() && !controller.isMangaLoading && !controller.isLoadingError {
                            VStack {
                                Image(systemName: "medal")
                                    .resizable()
                                    .frame(width: 40, height: 50)
                                Text("Nothing found")
                                    .bold()
                            }
                        }
                    }
                    .navigationTitle("Top Manga")
                }
            }
            .task(id: isRefresh) {
                if controller.shouldRefresh() || isRefresh {
                    await controller.refresh()
                    isRefresh = false
                }
            }
            .refreshable {
                isRefresh = true
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    TopFilter(controller: controller)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    AnimeMangaToggle(type: $controller.type, refresh: {
                        if controller.isItemsEmpty() {
                            await controller.refresh()
                        }
                    })
                }
            }
        }
    }
}

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
                                    ForEach(controller.animeItems, id: \.node.id) { item in
                                        AnimeGridItem(id: item.node.id, title: item.node.title, imageUrl: item.node.mainPicture?.medium, subtitle: rankToString(item.ranking?.rank))
                                            .task {
                                                await controller.loadMoreIfNeeded(currentItem: item)
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
                                    ForEach(controller.mangaItems, id: \.node.id) { item in
                                        MangaGridItem(id: item.node.id, title: item.node.title, imageUrl: item.node.mainPicture?.medium, subtitle: rankToString(item.ranking?.rank))
                                            .task {
                                                await controller.loadMoreIfNeeded(currentItem: item)
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
                AnimeMangaToggle(type: $controller.type, refresh: {
                    if controller.isItemsEmpty() {
                        await controller.refresh()
                    }
                })
            }
        }
    }
}

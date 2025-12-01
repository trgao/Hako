//
//  GroupDetailsView.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct GroupDetailsView: View {
    @StateObject private var controller: GroupDetailsViewController
    @State private var isRefresh = false
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150), alignment: .top),
    ]
    private let title: String
    private let urlExtend: String
    private let type: TypeEnum
    
    init(title: String, urlExtend: String, type: TypeEnum) {
        self.title = title
        self.urlExtend = urlExtend
        self.type = type
        self._controller = StateObject(wrappedValue: GroupDetailsViewController(urlExtend: urlExtend, type: type))
    }
    
    var body: some View {
        ZStack {
            if controller.isLoadingError && controller.items.isEmpty {
                ErrorView(refresh: controller.refresh)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(Array(controller.items.enumerated()), id: \.1.id) { index, item in
                            if type == .anime {
                                AnimeGridItem(id: item.id, title: item.title, enTitle: item.titleEnglish, imageUrl: item.images?.jpg?.largeImageUrl, anime: Anime(item: item))
                                    .task {
                                        await controller.loadMoreIfNeeded(index: index)
                                    }
                            } else if type == .manga {
                                MangaGridItem(id: item.id, title: item.title, enTitle: item.titleEnglish, imageUrl: item.images?.jpg?.largeImageUrl, manga: Manga(item: item))
                                    .task {
                                        await controller.loadMoreIfNeeded(index: index)
                                    }
                            }
                        }
                    }
                    .padding(10)
                    .task(id: isRefresh) {
                        if isRefresh {
                            await controller.refresh()
                            isRefresh = false
                        }
                    }
                    .refreshable {
                        isRefresh = true
                    }
                }
                if controller.isLoading {
                    LoadingView()
                }
            }
        }
        .navigationTitle(title)
    }
}

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
    private let title: String?
    private let group: String
    private let id: Int
    private let type: TypeEnum
    
    init(title: String?, group: String, id: Int, type: TypeEnum) {
        self.title = title
        self.group = String(group.dropLast())
        self.id = id
        self.type = type
        self._controller = StateObject(wrappedValue: GroupDetailsViewController(group: group, id: id, type: type))
    }
    
    var body: some View {
        ZStack {
            if controller.isLoadingError && controller.items.isEmpty {
                ErrorView(refresh: controller.refresh)
            } else if !controller.items.isEmpty {
                ScrollView {
                    LazyVGrid(columns: Constants.columns) {
                        ForEach(Array(controller.items.enumerated()), id: \.1.id) { index, item in
                            if type == .anime {
                                AnimeGridItem(id: item.id, title: item.title, enTitle: item.titleEnglish, imageUrl: item.images?.jpg?.largeImageUrl, anime: Anime(item: item))
                                    .onAppear {
                                        Task {
                                            await controller.loadMoreIfNeeded(index: index)
                                        }
                                    }
                            } else if type == .manga {
                                MangaGridItem(id: item.id, title: item.title, enTitle: item.titleEnglish, imageUrl: item.images?.jpg?.largeImageUrl, manga: Manga(item: item))
                                    .onAppear {
                                        Task {
                                            await controller.loadMoreIfNeeded(index: index)
                                        }
                                    }
                            }
                        }
                    }
                    .padding(10)
                }
                .task(id: isRefresh) {
                    if isRefresh {
                        await controller.refresh()
                        await controller.loadMore()
                        isRefresh = false
                    }
                }
                .refreshable {
                    isRefresh = true
                }
            } else if !controller.isLoading {
                VStack {
                    Image(systemName: "text.page.fill")
                        .resizable()
                        .frame(width: 30, height: 40)
                        .padding(.bottom, 10)
                    Text("Page not found")
                        .bold()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            if controller.isLoading {
                LoadingView()
            }
        }
        .navigationTitle(title ?? "")
        .toolbar {
            ShareLink(item: URL(string: "https://myanimelist.net/\(type.rawValue)/\(group)/\(id)")!) {
                Image(systemName: "square.and.arrow.up")
            }
        }
    }
}

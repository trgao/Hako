//
//  GroupDetailsView.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct GroupDetailsView: View {
    @StateObject var controller: GroupDetailsViewController
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
                        ForEach(controller.items) { item in
                            if type == .anime {
                                AnimeGridItem(id: item.id, title: item.title, enTitle: item.titleEnglish, imageUrl: item.images?.jpg?.largeImageUrl)
                                    .task {
                                        await controller.loadMoreIfNeeded(currentItem: item)
                                    }
                            } else if type == .manga {
                                MangaGridItem(id: item.id, title: item.title, enTitle: item.titleEnglish, imageUrl: item.images?.jpg?.largeImageUrl)
                                    .task {
                                        await controller.loadMoreIfNeeded(currentItem: item)
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
                .navigationTitle(title)
                if controller.isLoading {
                    LoadingView()
                }
            }
        }
    }
}

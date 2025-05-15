//
//  JikanGridInfiniteScrollView.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct JikanGridInfiniteScrollView: View {
    @StateObject var controller: JikanGridInfiniteScrollViewController
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
        self._controller = StateObject(wrappedValue: JikanGridInfiniteScrollViewController(urlExtend: urlExtend, type: type))
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
                                AnimeGridItem(id: item.id, title: item.title, imageUrl: item.images?.jpg.imageUrl)
                                    .task {
                                        await controller.loadMoreIfNeeded(currentItem: item)
                                    }
                            } else if type == .manga {
                                MangaGridItem(id: item.id, title: item.title, imageUrl: item.images?.jpg.imageUrl)
                                    .task {
                                        await controller.loadMoreIfNeeded(currentItem: item)
                                    }
                            }
                        }
                    }
                }
                .task {
                    await controller.refresh()
                }
                .navigationTitle(title)
                if controller.isLoading {
                    LoadingView()
                }
            }
        }
    }
}

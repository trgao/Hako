//
//  RelatedItems.swift
//  Hako
//
//  Created by Gao Tianrun on 6/5/24.
//

import SwiftUI

struct RelatedItems: View {
    private let relatedItems: [RelatedItem]?
    private let loadingState: LoadingEnum
    private let load: () async -> Void
    
    init(relatedItems: [RelatedItem]?, loadingState: LoadingEnum, load: @escaping () async -> Void) {
        self.relatedItems = relatedItems
        self.loadingState = loadingState
        self.load = load
    }
    
    var body: some View {
        ScrollViewCarousel(title: "Related", count: relatedItems?.count, loadingState: loadingState, refresh: load) {
            ForEach(relatedItems ?? []) { item in
                if item.type == .anime {
                    AnimeGridItem(id: item.id, title: item.title, enTitle: item.anime?.alternativeTitles?.en, imageUrl: item.anime?.mainPicture?.large, subtitle: item.relation, anime: item.anime)
                } else if item.type == .manga {
                    MangaGridItem(id: item.id, title: item.title, enTitle: item.manga?.alternativeTitles?.en, imageUrl: item.manga?.mainPicture?.large, subtitle: item.relation, manga: item.manga)
                }
            }
            .padding(-5)
        }
        .task {
            await load()
        }
    }
}

//
//  AnimeAdaptations.swift
//  Hako
//
//  Created by Gao Tianrun on 21/3/26.
//

import SwiftUI

struct AnimeAdaptations: View {
    private let relatedManga: [RelatedItem]?
    private let loadingState: LoadingEnum
    private let load: () async -> Void
    
    init(relatedManga: [RelatedItem]?, loadingState: LoadingEnum, load: @escaping () async -> Void) {
        self.relatedManga = relatedManga
        self.loadingState = loadingState
        self.load = load
    }
    
    var body: some View {
        ScrollViewCarousel(title: "Adaptations", count: relatedManga?.count, loadingState: loadingState, refresh: load) {
            ForEach(relatedManga ?? []) { item in
                MangaGridItem(id: item.id, title: item.title, enTitle: item.manga?.alternativeTitles?.en, imageUrl: item.manga?.mainPicture?.large, subtitle: item.manga?.mediaType?.formatMediaType(), manga: item.manga)
            }
            .padding(-5)
        }
        .task {
            await load()
        }
    }
}

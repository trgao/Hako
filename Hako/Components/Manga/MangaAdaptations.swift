//
//  MangaAdaptations.swift
//  Hako
//
//  Created by Gao Tianrun on 21/3/26.
//

import SwiftUI

struct MangaAdaptations: View {
    private let relatedAnime: [RelatedItem]?
    private let loadingState: LoadingEnum
    private let load: () async -> Void
    
    init(relatedAnime: [RelatedItem]?, loadingState: LoadingEnum, load: @escaping () async -> Void) {
        self.relatedAnime = relatedAnime
        self.loadingState = loadingState
        self.load = load
    }
    
    var body: some View {
        ScrollViewCarousel(title: "Adaptations", count: relatedAnime?.count, loadingState: loadingState, refresh: load) {
            ForEach(relatedAnime ?? []) { item in
                AnimeGridItem(id: item.id, title: item.title, enTitle: item.anime?.alternativeTitles?.en, imageUrl: item.anime?.mainPicture?.large, subtitle: item.anime?.mediaType?.formatMediaType(), anime: item.anime)
            }
            .padding(-5)
        }
        .task {
            await load()
        }
    }
}

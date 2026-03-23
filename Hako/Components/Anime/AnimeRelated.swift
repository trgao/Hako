//
//  AnimeRelated.swift
//  Hako
//
//  Created by Gao Tianrun on 21/3/26.
//

import SwiftUI

struct AnimeRelated: View {
    @State private var relatedPreview: [RelatedItem] = []
    private let relatedManga: [RelatedItem]?
    private let relatedAnime: [RelatedItem]?
    private let loadingState: LoadingEnum
    private let load: () async -> Void
    
    init(relatedManga: [RelatedItem]?, relatedAnime: [RelatedItem]?, loadingState: LoadingEnum, load: @escaping () async -> Void) {
        self.relatedManga = relatedManga
        self.relatedAnime = relatedAnime
        self.loadingState = loadingState
        self.load = load
    }
    
    var body: some View {
        ScrollViewCarousel(title: "Related manga", count: relatedManga?.count, loadingState: loadingState, refresh: load) {
            ForEach(relatedManga ?? []) { item in
                MangaGridItem(id: item.id, title: item.title, enTitle: item.manga?.alternativeTitles?.en, imageUrl: item.manga?.mainPicture?.large, subtitle: item.manga?.mediaType?.formatMediaType(), manga: item.manga)
            }
            .padding(-5)
        }
        .task {
            await load()
        }
        ScrollViewCarousel(title: "Related anime", count: relatedAnime?.count) {
            ForEach(relatedPreview) { item in
                AnimeGridItem(id: item.id, title: item.title, enTitle: item.anime?.alternativeTitles?.en, imageUrl: item.anime?.mainPicture?.large, subtitle: item.relation, anime: item.anime)
            }
            .padding(-5)
        } destination: {
            RelatedGridView(relatedAnime: relatedAnime)
        }
        .onAppear {
            relatedPreview = Array(relatedAnime?.prefix(10) ?? [])
        }
        .onChange(of: relatedAnime?.count) {
            relatedPreview = Array(relatedAnime?.prefix(10) ?? [])
        }
    }
}

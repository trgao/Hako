//
//  MangaRelated.swift
//  Hako
//
//  Created by Gao Tianrun on 21/3/26.
//

import SwiftUI

struct MangaRelated: View {
    @State private var relatedPreview: [RelatedItem] = []
    private let relatedAnime: [RelatedItem]?
    private let relatedManga: [RelatedItem]?
    private let loadingState: LoadingEnum
    private let load: () async -> Void
    
    init(relatedAnime: [RelatedItem]?, relatedManga: [RelatedItem]?, loadingState: LoadingEnum, load: @escaping () async -> Void) {
        self.relatedAnime = relatedAnime
        self.relatedManga = relatedManga
        self.loadingState = loadingState
        self.load = load
    }
    
    var body: some View {
        ScrollViewCarousel(title: "Related anime", count: relatedAnime?.count, loadingState: loadingState, refresh: load) {
            ForEach(relatedAnime ?? []) { item in
                AnimeGridItem(id: item.id, title: item.title, enTitle: item.anime?.alternativeTitles?.en, jaTitle: item.anime?.alternativeTitles?.ja, imageUrl: item.anime?.mainPicture?.large, subtitle: item.anime?.mediaType?.formatMediaType(), anime: item.anime)
            }
            .padding(-5)
        }
        .task {
            await load()
        }
        if let relatedManga = relatedManga {
            ScrollViewCarousel(title: "Related manga", count: relatedManga.count) {
                ForEach(relatedPreview) { item in
                    MangaGridItem(id: item.id, title: item.title, enTitle: item.manga?.alternativeTitles?.en, jaTitle: item.manga?.alternativeTitles?.ja, imageUrl: item.manga?.mainPicture?.large, subtitle: item.relation, manga: item.manga)
                }
                .padding(-5)
            } destination: {
                RelatedGridView(relatedManga: relatedManga)
            }
            .onAppear {
                relatedPreview = Array(relatedManga.prefix(10))
            }
            .onChange(of: relatedManga.count) {
                relatedPreview = Array(relatedManga.prefix(10))
            }
        }
    }
}

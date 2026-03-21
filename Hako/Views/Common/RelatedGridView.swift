//
//  RelatedGridView.swift
//  Hako
//
//  Created by Gao Tianrun on 21/3/26.
//

import SwiftUI

struct RelatedGridView: View {
    @Environment(\.screenRatio) private var screenRatio
    private let relatedAnime: [RelatedItem]?
    private let relatedManga: [RelatedItem]?
    
    init(relatedAnime: [RelatedItem]?) {
        self.relatedAnime = relatedAnime
        self.relatedManga = nil
    }
    
    init(relatedManga: [RelatedItem]?) {
        self.relatedAnime = nil
        self.relatedManga = relatedManga
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150 * screenRatio), spacing: 5, alignment: .top)]) {
                if let relatedAnime = relatedAnime {
                    ForEach(relatedAnime) { item in
                        AnimeGridItem(id: item.id, title: item.title, enTitle: item.anime?.alternativeTitles?.en, imageUrl: item.anime?.mainPicture?.large, subtitle: item.relation, anime: item.anime)
                    }
                } else if let relatedManga = relatedManga {
                    ForEach(relatedManga) { item in
                        MangaGridItem(id: item.id, title: item.title, enTitle: item.manga?.alternativeTitles?.en, imageUrl: item.manga?.mainPicture?.large, subtitle: item.relation, manga: item.manga)
                    }
                }
            }
            .padding(10)
        }
        .navigationTitle("Related")
    }
}

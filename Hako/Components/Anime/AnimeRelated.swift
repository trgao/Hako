//
//  AnimeRelated.swift
//  Hako
//
//  Created by Gao Tianrun on 21/3/26.
//

import SwiftUI

struct AnimeRelated: View {
    @State private var relatedPreview: [RelatedItem] = []
    private let relatedAnime: [RelatedItem]?
    
    init(relatedAnime: [RelatedItem]?) {
        self.relatedAnime = relatedAnime
    }
    
    var body: some View {
        ScrollViewCarousel(title: "Related", count: relatedAnime?.count) {
            ForEach(relatedPreview) { item in
                AnimeGridItem(id: item.id, title: item.title, enTitle: item.anime?.alternativeTitles?.en, imageUrl: item.anime?.mainPicture?.large, subtitle: item.relation, anime: item.anime)
            }
            .padding(-5)
        } destination: {
            RelatedGridView(relatedAnime: relatedAnime)
        }
        .onChange(of: relatedAnime?.count) {
            relatedPreview = Array(relatedAnime?.prefix(10) ?? [])
        }
    }
}

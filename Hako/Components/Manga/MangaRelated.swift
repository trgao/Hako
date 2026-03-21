//
//  MangaRelated.swift
//  Hako
//
//  Created by Gao Tianrun on 21/3/26.
//

import SwiftUI

struct MangaRelated: View {
    private let relatedManga: [RelatedItem]?
    
    init(relatedManga: [RelatedItem]?) {
        self.relatedManga = relatedManga
    }
    
    var body: some View {
        ScrollViewCarousel(title: "Related", count: relatedManga?.count) {
            ForEach(relatedManga?.prefix(10) ?? []) { item in
                MangaGridItem(id: item.id, title: item.title, enTitle: item.manga?.alternativeTitles?.en, imageUrl: item.manga?.mainPicture?.large, subtitle: item.relation, manga: item.manga)
            }
            .padding(-5)
        } destination: {
            RelatedGridView(relatedManga: relatedManga)
        }
    }
}

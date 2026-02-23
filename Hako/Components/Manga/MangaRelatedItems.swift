//
//  MangaRelatedItems.swift
//  Hako
//
//  Created by Gao Tianrun on 6/5/24.
//

import SwiftUI

struct MangaRelatedItems: View {
    @StateObject private var controller: MangaDetailsViewController
    
    init(controller: MangaDetailsViewController) {
        self._controller = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        VStack {
            if !controller.relatedItems.isEmpty {
                ScrollViewCarousel(title: "Related") {
                    ForEach(controller.relatedItems) { item in
                        if item.type == .anime {
                            AnimeGridItem(id: item.id, title: item.title, enTitle: item.anime?.alternativeTitles?.en, imageUrl: item.anime?.mainPicture?.large, subtitle: item.relation, anime: item.anime)
                        } else if item.type == .manga {
                            MangaGridItem(id: item.id, title: item.title, enTitle: item.manga?.alternativeTitles?.en, imageUrl: item.manga?.mainPicture?.large, subtitle: item.relation, manga: item.manga)
                        }
                    }
                }
            }
        }
        .task {
            await controller.loadRelated()
        }
    }
}

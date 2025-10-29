//
//  AnimeRelatedItems.swift
//  Hako
//
//  Created by Gao Tianrun on 6/5/24.
//

import SwiftUI

struct AnimeRelatedItems: View {
    @StateObject private var controller: AnimeDetailsViewController
    
    init(controller: AnimeDetailsViewController) {
        self._controller = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        VStack {
            if !controller.relatedItems.isEmpty {
                ScrollViewCarousel(title: "Related", items: controller.relatedItems, showLink: false) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            ForEach(controller.relatedItems) { item in
                                if item.type == .anime {
                                    AnimeGridItem(id: item.id, title: item.title, enTitle: item.anime?.alternativeTitles?.en, imageUrl: item.anime?.mainPicture?.medium, subtitle: item.relation, anime: item.anime)
                                } else if item.type == .manga {
                                    MangaGridItem(id: item.id, title: item.title, enTitle: item.manga?.alternativeTitles?.en, imageUrl: item.manga?.mainPicture?.medium, subtitle: item.relation, manga: item.manga)
                                }
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                }
            }
        }
        .task {
            await controller.loadRelated()
        }
    }
}

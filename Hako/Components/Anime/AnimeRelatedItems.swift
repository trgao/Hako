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
        if !controller.relatedItems.isEmpty {
            ScrollViewCarousel(title: "Related", items: controller.relatedItems, showLink: false) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top) {
                        ForEach(controller.relatedItems) { item in
                            if item.type == .anime {
                                AnimeGridItem(id: item.id, title: item.title, enTitle: item.enTitle, imageUrl: item.imageUrl, subtitle: item.relation)
                            } else if item.type == .manga {
                                MangaGridItem(id: item.id, title: item.title, enTitle: item.enTitle, imageUrl: item.imageUrl, subtitle: item.relation)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

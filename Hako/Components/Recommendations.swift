//
//  Recommendations.swift
//  Hako
//
//  Created by Gao Tianrun on 14/5/24.
//

import SwiftUI

struct Recommendations: View {
    private var animeRecommendations = [MALListAnime]()
    private var mangaRecommendations = [MALListManga]()
    private let type: TypeEnum
    
    init(animeRecommendations: [MALListAnime]?) {
        self.animeRecommendations = animeRecommendations ?? []
        type = .anime
    }
    
    init(mangaRecommendations: [MALListManga]?) {
        self.mangaRecommendations = mangaRecommendations ?? []
        type = .manga
    }
    
    var body: some View {
        if type == .anime && !animeRecommendations.isEmpty {
            ScrollViewCarousel(title: "Recommendations", spacing: 15) {
                ForEach(animeRecommendations) { item in
                    AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large, anime: item.node)
                }
                .padding(-5)
            }
        } else if type == .manga && !mangaRecommendations.isEmpty {
            ScrollViewCarousel(title: "Recommendations", spacing: 15) {
                ForEach(mangaRecommendations) { item in
                    MangaGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large, manga: item.node)
                }
                .padding(-5)
            }
        }
    }
}

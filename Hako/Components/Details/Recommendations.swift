//
//  Recommendations.swift
//  Hako
//
//  Created by Gao Tianrun on 14/5/24.
//

import SwiftUI

struct Recommendations: View {
    private var animeRecommendations: [MALListAnime]?
    private var mangaRecommendations: [MALListManga]?
    
    init(animeRecommendations: [MALListAnime]?) {
        self.animeRecommendations = animeRecommendations
    }
    
    init(mangaRecommendations: [MALListManga]?) {
        self.mangaRecommendations = mangaRecommendations
    }
    
    var body: some View {
        if let recommendations = animeRecommendations, !recommendations.isEmpty {
            ScrollViewCarousel(title: "Recommendations", spacing: 15) {
                ForEach(recommendations) { item in
                    AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large, anime: item.node)
                }
                .padding(-5)
            }
        } else if let recommendations = mangaRecommendations, !recommendations.isEmpty {
            ScrollViewCarousel(title: "Recommendations", spacing: 15) {
                ForEach(recommendations) { item in
                    MangaGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large, manga: item.node)
                }
                .padding(-5)
            }
        }
    }
}

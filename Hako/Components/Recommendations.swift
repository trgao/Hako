//
//  Recommendations.swift
//  Hako
//
//  Created by Gao Tianrun on 14/5/24.
//

import SwiftUI

struct Recommendations: View {
    @State private var animeRecommendations = [MALListAnime]()
    @State private var mangaRecommendations = [MALListManga]()
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
            ScrollViewCarousel(title: "Recommendations") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top) {
                        ForEach(animeRecommendations) { item in
                            AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large)
                        }
                    }
                    .padding(.horizontal, 15)
                }
            }
        } else if type == .manga && !mangaRecommendations.isEmpty {
            ScrollViewCarousel(title: "Recommendations") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top) {
                        ForEach(mangaRecommendations) { item in
                            MangaGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large)
                        }
                    }
                    .padding(.horizontal, 15)
                }
            }
        }
    }
}

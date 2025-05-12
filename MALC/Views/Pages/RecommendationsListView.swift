//
//  RecommendationsListView.swift
//  MALC
//
//  Created by Gao Tianrun on 14/5/24.
//

import SwiftUI

struct RecommendationsListView: View {
    private let animeRecommendations: [MALListAnime]
    private let mangaRecommendations: [MALListManga]
    
    init(animeRecommendations: [MALListAnime]) {
        self.animeRecommendations = animeRecommendations
        self.mangaRecommendations = []
    }
    
    init(mangaRecommendations: [MALListManga]) {
        self.animeRecommendations = []
        self.mangaRecommendations = mangaRecommendations
    }
    
    var body: some View {
        ZStack {
            List {
                ForEach(animeRecommendations) { item in
                    NavigationLink {
                        AnimeDetailsView(id: item.id, imageUrl: item.node.mainPicture?.medium)
                    } label: {
                        HStack {
                            ImageFrame(id: "anime\(item.id)", imageUrl: item.node.mainPicture?.medium, imageSize: .small)
                                .padding([.trailing], 10)
                            VStack(alignment: .leading) {
                                Text(item.node.title)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                ForEach(mangaRecommendations) { item in
                    NavigationLink {
                        MangaDetailsView(id: item.id, imageUrl: item.node.mainPicture?.medium)
                    } label: {
                        HStack {
                            ImageFrame(id: "manga\(item.id)", imageUrl: item.node.mainPicture?.medium, imageSize: .small)
                                .padding([.trailing], 10)
                            VStack(alignment: .leading) {
                                Text(item.node.title)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Recommendations")
            .background(Color(.systemGray6))
        }
    }
}

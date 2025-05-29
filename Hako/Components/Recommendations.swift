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
            Section {} header: {
                VStack {
                    Text("Recommendations")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 35)
                        .font(.system(size: 17))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            ForEach(animeRecommendations) { item in
                                AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .textCase(nil)
                .padding(.horizontal, -20)
                .foregroundColor(Color.primary)
                .listRowInsets(.init())
            }
            .listRowInsets(.init())
        } else if type == .manga && !mangaRecommendations.isEmpty {
            Section {} header: {
                VStack {
                    Text("Recommendations")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 35)
                        .font(.system(size: 17))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            ForEach(mangaRecommendations) { item in
                                NavigationLink {
                                    MangaDetailsView(id: item.id)
                                } label: {
                                    MangaGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .textCase(nil)
                .padding(.horizontal, -20)
                .foregroundColor(Color.primary)
                .listRowInsets(.init())
            }
            .listRowInsets(.init())
        }
    }
}

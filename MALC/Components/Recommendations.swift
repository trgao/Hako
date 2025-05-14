//
//  Recommendations.swift
//  MALC
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
                    NavigationLink {
                        RecommendationsListView(animeRecommendations: animeRecommendations)
                    } label: {
                        HStack {
                            Text("Recommendations")
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color(.systemGray2))
                        }
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 30)
                        .font(.system(size: 17))
                    }
                    .buttonStyle(.plain)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            Rectangle()
                                .frame(width: 5)
                                .foregroundColor(.clear)
                            ForEach(animeRecommendations) { item in
                                AnimeGridItem(id: item.id, title: item.node.title, imageUrl: item.node.mainPicture?.medium)
                            }
                            Rectangle()
                                .frame(width: 5)
                                .foregroundColor(.clear)
                        }
                    }
                }
                .textCase(nil)
                .padding(.horizontal, -15)
                .foregroundColor(Color.primary)
                .listRowInsets(.init())
            }
            .listRowInsets(.init())
        } else if type == .manga && !mangaRecommendations.isEmpty {
            Section {} header: {
                VStack {
                    NavigationLink {
                        RecommendationsListView(mangaRecommendations: mangaRecommendations)
                    } label: {
                        HStack {
                            Text("Recommendations")
                                .bold()
                            Image(systemName: "chevron.right")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 30)
                        .font(.system(size: 17))
                    }
                    .buttonStyle(.plain)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            Rectangle()
                                .frame(width: 5)
                                .foregroundColor(.clear)
                            ForEach(mangaRecommendations) { item in
                                NavigationLink {
                                    MangaDetailsView(id: item.id, imageUrl: item.node.mainPicture?.medium)
                                } label: {
                                    MangaGridItem(id: item.id, title: item.node.title, imageUrl: item.node.mainPicture?.medium)
                                }
                                .buttonStyle(.plain)
                            }
                            Rectangle()
                                .frame(width: 5)
                                .foregroundColor(.clear)
                        }
                    }
                }
                .textCase(nil)
                .padding(.horizontal, -15)
                .foregroundColor(Color.primary)
                .listRowInsets(.init())
            }
            .listRowInsets(.init())
        }
    }
}

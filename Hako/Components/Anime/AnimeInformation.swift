//
//  AnimeInformation.swift
//  Hako
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

struct AnimeInformation: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private let anime: Anime
    private let isEmpty: Bool
    
    init(anime: Anime) {
        self.anime = anime
        self.isEmpty = anime.source == nil && anime.rating == nil && (anime.studios?.isEmpty ?? true) && (anime.genres?.isEmpty ?? true) && anime.startDate == nil
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Information")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
            if dynamicTypeSize <= .xxLarge {
                HStack {
                    ScrollViewBox(title: "Rank", image: "medal.fill", content: "\(anime.rank == nil ? "N/A" : "\(anime.rank!)")")
                    ScrollViewBox(title: "Popularity", image: "popcorn.fill", content: "\(anime.popularity == nil ? "N/A" : "\(anime.popularity!)")")
                    ScrollViewBox(title: "Members", image: "person.2.fill", content: "\(anime.numListUsers == nil ? "N/A" :  "\(anime.numListUsers!.formatted(.number.notation(.compactName)))")")
                }
            }
            if !isEmpty {
                VStack(spacing: 0) {
                    if dynamicTypeSize > .xxLarge {
                        ScrollViewRow(title: "Rank", content: "#\(anime.rank == nil ? "N/A" : "\(anime.rank!)")")
                        ScrollViewRow(title: "Popularity", content: "#\(anime.popularity == nil ? "N/A" : "\(anime.popularity!)")")
                        ScrollViewRow(title: "Members", content: "\(anime.numListUsers == nil ? "N/A" :  "\(anime.numListUsers!.formatted(.number.notation(.compactName)))")")
                    }
                    if let source = anime.source {
                        ScrollViewRow(title: "Source", content: "\(source.formatMediaType())", icon: Constants.mediaTypeIcons[source.toSnakeCase()])
                    }
                    if let rating = anime.rating, let ratingText = Constants.ratings[rating] {
                        ScrollViewRow(title: "Rating", content: ratingText)
                    }
                    if let startDate = anime.startDate {
                        ScrollViewRow(title: "Aired", content: "\(startDate.toString()) to \(anime.endDate?.toString() ?? "?")")
                    }
                    if let studios = anime.studios, !studios.isEmpty {
                        ScrollViewNavigationLink(title: "Studios", items: studios.map{ $0.name }) {
                            GroupsListView(title: "Studios", items: studios, group: "producers", type: .anime)
                        }
                    }
                    if let genres = anime.genres, !genres.isEmpty {
                        ScrollViewNavigationLink(title: "Genres", items: genres.map{ $0.name }) {
                            GroupsListView(title: "Genres", items: genres, group: "genres", type: .anime)
                        }
                    }
                    if let alternativeTitles = anime.alternativeTitles {
                        let titles = [anime.title, alternativeTitles.en, alternativeTitles.ja].compactMap { $0 }.filter { !$0.isEmpty }
                        ScrollViewRow(title: "Titles", content: "\(titles.joined(separator: ",\n"))")
                    }
                }
                .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 17)
    }
}

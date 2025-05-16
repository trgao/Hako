//
//  AnimeInformation.swift
//  Hako
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

struct AnimeInformation: View {
    private let anime: Anime
    
    init(anime: Anime) {
        self.anime = anime
    }
    
    var body: some View {
        Section {
            if let source = anime.source {
                ListRow(title: "Source", content: "\(source.replacingOccurrences(of: "_", with: " ").capitalized)")
            }
            if let rank = anime.rank {
                ListRow(title: "Rank", content: "#\(rank)")
            }
            if let popularity = anime.popularity {
                ListRow(title: "Popularity", content: "#\(popularity)")
            }
            if let startDate = anime.startDate {
                ListRow(title: "Start date", content: startDate.toString())
            }
            if let endDate = anime.endDate {
                ListRow(title: "End date", content: endDate.toString())
            }
            if let broadcast = anime.broadcast, let dayOfTheWeek = broadcast.dayOfTheWeek, let startTime = broadcast.startTime {
                ListRow(title: "Broadcast", content: "\(dayOfTheWeek.capitalized), \(startTime) (JST)")
            }
            if let rating = anime.rating {
                ListRow(title: "Rating", content: "\(rating.filter { $0 != "_" }.uppercased())")
            }
            if let studios = anime.studios, !studios.isEmpty {
                VStack {
                    NavigationLink {
                        GroupsListView(title: "Studios", items: studios, group: "producers", type: .anime)
                    } label: {
                        ListRow(title: "Studios", content: "\(studios.map{ $0.name }.joined(separator: ", "))")
                    }
                    .buttonStyle(.plain)
                }
            }
            if let genres = anime.genres, !genres.isEmpty {
                NavigationLink {
                    GroupsListView(title: "Genres", items: genres, group: "genres", type: .anime)
                } label: {
                    ListRow(title: "Genres", content: "\(genres.map{ $0.name }.joined(separator: ", "))")
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text("Information")
                .textCase(nil)
                .foregroundColor(Color.primary)
                .font(.system(size: 17))
                .bold()
        }
    }
}

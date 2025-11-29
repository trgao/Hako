//
//  AnimeInformation.swift
//  Hako
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

struct AnimeInformation: View {
    @Environment(\.screenSize) private var screenSize
    private let anime: Anime
    private let isEmpty: Bool
    
    init(anime: Anime) {
        self.anime = anime
        self.isEmpty = anime.source == nil && anime.rank == nil && anime.popularity == nil && anime.startDate == nil && anime.endDate == nil && (anime.broadcast == nil || (anime.broadcast?.dayOfTheWeek == nil && anime.broadcast?.startTime == nil)) && anime.rating == nil && anime.numListUsers == nil && (anime.studios == nil || anime.studios!.isEmpty) && (anime.genres == nil || anime.genres!.isEmpty)
    }
    
    var body: some View {
        if !isEmpty {
            ScrollViewSection(title: "Information") {
                if let source = anime.source {
                    ScrollViewRow(title: "Source", content: "\(source.replacingOccurrences(of: "_", with: " ").capitalized)")
                }
                if let rank = anime.rank {
                    ScrollViewRow(title: "Rank", content: "#\(rank)")
                }
                if let popularity = anime.popularity {
                    ScrollViewRow(title: "Popularity", content: "#\(popularity)")
                }
                if let startDate = anime.startDate {
                    ScrollViewRow(title: "Start date", content: startDate.toString())
                }
                if let endDate = anime.endDate {
                    ScrollViewRow(title: "End date", content: endDate.toString())
                }
                if let broadcast = anime.broadcast, let dayOfTheWeek = broadcast.dayOfTheWeek, let startTime = broadcast.startTime {
                    ScrollViewRow(title: "Broadcast", content: "\(dayOfTheWeek.capitalized), \(startTime) (JST)")
                }
                if let rating = anime.rating {
                    ScrollViewRow(title: "Rating", content: "\(rating.filter { $0 != "_" }.uppercased())")
                }
                if let numListUsers = anime.numListUsers {
                    ScrollViewRow(title: "Members", content: "\(numListUsers.formatted(.number.grouping(.automatic)))")
                }
                if let studios = anime.studios, !studios.isEmpty {
                    ScrollViewNavigationLink(title: "Studios", content: studios.map{ $0.name }.joined(separator: ", ")) {
                        GroupsListView(title: "Studios", items: studios, group: "producers", type: .anime)
                    }
                }
                if let genres = anime.genres, !genres.isEmpty {
                    ScrollViewNavigationLink(title: "Genres", content: genres.map{ $0.name }.joined(separator: ", ")) {
                        GroupsListView(title: "Genres", items: genres, group: "genres", type: .anime)
                    }
                }
            }
            .frame(width: screenSize.width)
        }
    }
}

//
//  AnimeInformation.swift
//  MALC
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
                HStack {
                    Text("Source")
                        .bold()
                    Spacer()
                    Text("\(source.replacingOccurrences(of: "_", with: " ").capitalized)")
                }
            }
            if let rank = anime.rank {
                HStack {
                    Text("Rank")
                        .bold()
                    Spacer()
                    Text("#\(rank)")
                }
            }
            if let popularity = anime.popularity {
                HStack {
                    Text("Popularity")
                        .bold()
                    Spacer()
                    Text("#\(popularity)")
                }
            }
            if let numListUsers = anime.numListUsers {
                HStack {
                    Text("Users")
                        .bold()
                    Spacer()
                    Text(String(numListUsers))
                }
            }
            if let startDate = anime.startDate {
                HStack {
                    Text("Start date")
                        .bold()
                    Spacer()
                    Text(startDate.toString())
                }
            }
            if let endDate = anime.endDate {
                HStack {
                    Text("End date")
                        .bold()
                    Spacer()
                    Text(endDate.toString())
                }
            }
            if let broadcast = anime.broadcast, let dayOfTheWeek = broadcast.dayOfTheWeek, let startTime = broadcast.startTime {
                HStack {
                    Text("Broadcast")
                        .bold()
                    Spacer()
                    Text("\(dayOfTheWeek.capitalized), \(startTime) (JST)")
                }
            }
            if let rating = anime.rating {
                HStack {
                    Text("Rating")
                        .bold()
                    Spacer()
                    Text("\(rating.filter { $0 != "_" }.uppercased())")
                }
            }
            if !anime.studios.isEmpty {
                VStack {
                    NavigationLink {
                        GroupsListView(title: "Studios", items: anime.studios, group: "producers", type: .anime)
                    } label: {
                        HStack {
                            Text("Studios")
                                .bold()
                            Spacer()
                            Text("\(anime.studios.map{ $0.name }.joined(separator: ", "))")
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            if !anime.genres.isEmpty {
                NavigationLink {
                    GroupsListView(title: "Genres", items: anime.genres, group: "genres", type: .anime)
                } label: {
                    HStack {
                        Text("Genres")
                            .bold()
                        Spacer()
                        Text("\(anime.genres.map{ $0.name }.joined(separator: ", "))")
                    }
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

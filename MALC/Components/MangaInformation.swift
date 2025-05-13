//
//  MangaInformation.swift
//  MALC
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

struct MangaInformation: View {
    private let manga: Manga
    
    init(manga: Manga) {
        self.manga = manga
    }
    
    var body: some View {
        Section {
            if let rank = manga.rank {
                HStack {
                    Text("Rank")
                        .bold()
                    Spacer()
                    Text("#\(rank)")
                }
            }
            if let popularity = manga.popularity {
                HStack {
                    Text("Popularity")
                        .bold()
                    Spacer()
                    Text("#\(popularity)")
                }
            }
            if let numListUsers = manga.numListUsers {
                HStack {
                    Text("Users")
                        .bold()
                    Spacer()
                    Text(String(numListUsers))
                }
            }
            if let startDate = manga.startDate {
                HStack {
                    Text("Start date")
                        .bold()
                    Spacer()
                    Text(startDate.toString())
                }
            }
            if let endDate = manga.endDate {
                HStack {
                    Text("End date")
                        .bold()
                    Spacer()
                    Text(endDate.toString())
                }
            }
            if !manga.serialization.isEmpty {
                NavigationLink {
                    GroupsListView(title: "Serialization", items: manga.serialization.map{ $0.node }, group: "magazines", type: .manga)
                } label: {
                    HStack {
                        Text("Serialization")
                            .bold()
                        Spacer()
                        Text("\(manga.serialization.map{ $0.node.name }.joined(separator: ", "))")
                    }
                }
                .buttonStyle(.plain)
            }
            if !manga.genres.isEmpty {
                NavigationLink {
                    GroupsListView(title: "Genres", items: manga.genres, group: "genres", type: .manga)
                } label: {
                    HStack {
                        Text("Genres")
                            .bold()
                        Spacer()
                        Text("\(manga.genres.map{ $0.name }.joined(separator: ", "))")
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

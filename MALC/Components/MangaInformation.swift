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
                ListRow(title: "Rank", content: "#\(rank)")
            }
            if let popularity = manga.popularity {
                ListRow(title: "Popularity", content: "#\(popularity)")
            }
            if let startDate = manga.startDate {
                ListRow(title: "Start date", content: startDate.toString())
            }
            if let endDate = manga.endDate {
                ListRow(title: "End date", content: endDate.toString())
            }
            if let serialization = manga.serialization, !serialization.isEmpty {
                NavigationLink {
                    GroupsListView(title: "Serialization", items: serialization.map{ $0.node }, group: "magazines", type: .manga)
                } label: {
                    ListRow(title: "Serialization", content: "\(serialization.map{ $0.node.name }.joined(separator: ", "))")
                }
                .buttonStyle(.plain)
            }
            if let genres = manga.genres, !genres.isEmpty {
                NavigationLink {
                    GroupsListView(title: "Genres", items: genres, group: "genres", type: .manga)
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

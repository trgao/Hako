//
//  MangaInformation.swift
//  Hako
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

struct MangaInformation: View {
    @Environment(\.screenSize) private var screenSize
    private let manga: Manga
    private let isEmpty: Bool
    
    init(manga: Manga) {
        self.manga = manga
        self.isEmpty = manga.rank == nil && manga.popularity == nil && manga.startDate == nil && manga.endDate == nil && manga.numListUsers == nil && (manga.serialization == nil || manga.serialization!.isEmpty) && (manga.genres == nil || manga.genres!.isEmpty)
    }
    
    var body: some View {
        if !isEmpty {
            ScrollViewSection(title: "Information") {
                if let rank = manga.rank {
                    ScrollViewRow(title: "Rank", content: "#\(rank)")
                }
                if let popularity = manga.popularity {
                    ScrollViewRow(title: "Popularity", content: "#\(popularity)")
                }
                if let startDate = manga.startDate {
                    ScrollViewRow(title: "Start date", content: startDate.toString())
                }
                if let endDate = manga.endDate {
                    ScrollViewRow(title: "End date", content: endDate.toString())
                }
                if let numListUsers = manga.numListUsers {
                    ScrollViewRow(title: "Members", content: "\(numListUsers.formatted(.number.grouping(.automatic)))")
                }
                if let serialization = manga.serialization, !serialization.isEmpty {
                    ScrollViewNavigationLink(title: "Serialization", content: serialization.map{ $0.node.name }.joined(separator: ", ")) {
                        GroupsListView(title: "Serialization", items: serialization.map{ $0.node }, group: "magazines", type: .manga)
                    }
                }
                if let genres = manga.genres, !genres.isEmpty {
                    ScrollViewNavigationLink(title: "Genres", content: genres.map{ $0.name }.joined(separator: ", ")) {
                        GroupsListView(title: "Genres", items: genres, group: "genres", type: .manga)
                    }
                }
            }
            .frame(width: screenSize.width)
        }
    }
}

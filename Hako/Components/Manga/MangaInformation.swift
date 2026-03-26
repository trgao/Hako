//
//  MangaInformation.swift
//  Hako
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

struct MangaInformation: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private let manga: Manga
    private let isEmpty: Bool
    
    init(manga: Manga) {
        self.manga = manga
        self.isEmpty = (manga.serialization?.isEmpty ?? true) && (manga.genres?.isEmpty ?? true) && manga.startDate == nil
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Information")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
            if dynamicTypeSize <= .xxxLarge {
                HStack {
                    ScrollViewBox(title: "Rank", image: "medal.fill", content: "\(manga.rank == nil ? "N/A" : "\(manga.rank!)")")
                    ScrollViewBox(title: "Popularity", image: "popcorn.fill", content: "\(manga.popularity == nil ? "N/A" : "\(manga.popularity!)")")
                    ScrollViewBox(title: "Members", image: "person.2.fill", content: "\(manga.numListUsers == nil ? "N/A" :  "\(manga.numListUsers!.formatted(.number.notation(.compactName)))")")
                }
            }
            if !isEmpty {
                VStack(spacing: 0) {
                    if dynamicTypeSize > .xxxLarge {
                        ScrollViewRow(title: "Rank", content: "#\(manga.rank == nil ? "N/A" : "\(manga.rank!)")")
                        ScrollViewRow(title: "Popularity", content: "#\(manga.popularity == nil ? "N/A" : "\(manga.popularity!)")")
                        ScrollViewRow(title: "Members", content: "\(manga.numListUsers == nil ? "N/A" :  "\(manga.numListUsers!.formatted(.number.notation(.compactName)))")")
                    }
                    if let startDate = manga.startDate {
                        ScrollViewRow(title: "Serialised", content: "\(startDate.toString()) to \(manga.endDate?.toString() ?? "?")")
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
                    if let alternativeTitles = manga.alternativeTitles {
                        let titles = [manga.title, alternativeTitles.en, alternativeTitles.ja].compactMap { $0 }.filter { !$0.isEmpty }
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

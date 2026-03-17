//
//  ExploreMangaView.swift
//  Hako
//
//  Created by Gao Tianrun on 20/7/25.
//

import SwiftUI

struct ExploreMangaView: View {
    var body: some View {
        List {
            Section("Genres") {
                ForEach(Constants.mangaGenreKeys, id: \.self) { id in
                    NavigationLink(Constants.mangaGenres[id] ?? "") {
                        GroupDetailsView(title: Constants.mangaGenres[id], group: "genres", id: id, type: .manga)
                    }
                    .buttonStyle(.plain)
                }
            }
            Section("Themes") {
                ForEach(Constants.mangaThemeKeys, id: \.self) { id in
                    NavigationLink(Constants.mangaThemes[id] ?? "") {
                        GroupDetailsView(title: Constants.mangaThemes[id], group: "genres", id: id, type: .manga)
                    }
                    .buttonStyle(.plain)
                }
            }
            Section("Demographics") {
                ForEach(Constants.mangaDemographicKeys, id: \.self) { id in
                    NavigationLink(Constants.mangaDemographics[id] ?? "") {
                        GroupDetailsView(title: Constants.mangaDemographics[id], group: "genres", id: id, type: .manga)
                    }
                    .buttonStyle(.plain)
                }
            }
            NavigationLink {
                MagazinesListView()
            } label: {
                Text("Magazines")
            }
            .buttonStyle(.plain)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Manga")
    }
}

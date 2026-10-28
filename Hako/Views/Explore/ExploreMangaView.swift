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
                    if let genre = Constants.mangaGenres[id] {
                        NavigationLink(genre, value: Route.groupDetail(GroupDetail(id: id, name: genre, type: .manga, group: "genres")))
                    }
                }
            }
            Section("Themes") {
                ForEach(Constants.mangaThemeKeys, id: \.self) { id in
                    if let theme = Constants.mangaThemes[id] {
                        NavigationLink(theme, value: Route.groupDetail(GroupDetail(id: id, name: theme, type: .manga, group: "genres")))
                    }
                }
            }
            Section("Demographics") {
                ForEach(Constants.mangaDemographicKeys, id: \.self) { id in
                    if let demographic = Constants.mangaDemographics[id] {
                        NavigationLink(demographic, value: Route.groupDetail(GroupDetail(id: id, name: demographic, type: .manga, group: "genres")))
                    }
                }
            }
            NavigationLink("Magazines", value: Route.screen(.magazines))

        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Manga")
    }
}

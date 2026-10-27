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
                        TrackedNavigationLink(value: GroupDetail(id: id, name: genre, type: .manga, group: "genres"), label: genre)
                    }
                }
            }
            Section("Themes") {
                ForEach(Constants.mangaThemeKeys, id: \.self) { id in
                    if let theme = Constants.mangaThemes[id] {
                        TrackedNavigationLink(value: GroupDetail(id: id, name: theme, type: .manga, group: "genres"), label: theme)
                    }
                }
            }
            Section("Demographics") {
                ForEach(Constants.mangaDemographicKeys, id: \.self) { id in
                    if let demographic = Constants.mangaDemographics[id] {
                        TrackedNavigationLink(value: GroupDetail(id: id, name: demographic, type: .manga, group: "genres"), label: demographic)
                    }
                }
            }
            TrackedNavigationLink(value: "magazines", label: "Magazines")

        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Manga")
    }
}

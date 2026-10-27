//
//  ExploreAnimeView.swift
//  Hako
//
//  Created by Gao Tianrun on 20/7/25.
//

import SwiftUI

struct ExploreAnimeView: View {
    var body: some View {
        List {
            Section("Genres") {
                ForEach(Constants.animeGenreKeys, id: \.self) { id in
                    if let genre = Constants.animeGenres[id] {
                        TrackedNavigationLink(value: GroupDetail(id: id, name: genre, type: .anime, group: "genres"), label: genre)
                    }
                }
            }
            Section("Themes") {
                ForEach(Constants.animeThemeKeys, id: \.self) { id in
                    if let theme = Constants.animeThemes[id] {
                        TrackedNavigationLink(value: GroupDetail(id: id, name: theme, type: .anime, group: "genres"), label: theme)
                    }
                }
            }
            Section("Demographics") {
                ForEach(Constants.animeDemographicKeys, id: \.self) { id in
                    if let demographic = Constants.animeDemographics[id] {
                        TrackedNavigationLink(value: GroupDetail(id: id, name: demographic, type: .anime, group: "genres"), label: demographic)
                    }
                }
            }
            TrackedNavigationLink(value: "companies", label: "Companies")
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Anime")
    }
}

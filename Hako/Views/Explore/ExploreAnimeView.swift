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
                        NavigationLink(genre, value: Route.groupDetail(GroupDetail(id: id, name: genre, type: .anime, group: "genres")))
                    }
                }
            }
            Section("Themes") {
                ForEach(Constants.animeThemeKeys, id: \.self) { id in
                    if let theme = Constants.animeThemes[id] {
                        NavigationLink(theme, value: Route.groupDetail(GroupDetail(id: id, name: theme, type: .anime, group: "genres")))
                    }
                }
            }
            Section("Demographics") {
                ForEach(Constants.animeDemographicKeys, id: \.self) { id in
                    if let demographic = Constants.animeDemographics[id] {
                        NavigationLink(demographic, value: Route.groupDetail(GroupDetail(id: id, name: demographic, type: .anime, group: "genres")))
                    }
                }
            }
            NavigationLink("Companies", value: Route.screen(.companies))
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Anime")
    }
}

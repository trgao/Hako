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
                    NavigationLink(Constants.animeGenres[id] ?? "") {
                        GroupDetailsView(title: Constants.animeGenres[id], group: "genres", id: id, type: .anime)
                    }
                    .buttonStyle(.plain)
                }
            }
            Section("Themes") {
                ForEach(Constants.animeThemeKeys, id: \.self) { id in
                    NavigationLink(Constants.animeThemes[id] ?? "") {
                        GroupDetailsView(title: Constants.animeThemes[id], group: "genres", id: id, type: .anime)
                    }
                    .buttonStyle(.plain)
                }
            }
            Section("Demographics") {
                ForEach(Constants.animeDemographicKeys, id: \.self) { id in
                    NavigationLink(Constants.animeDemographics[id] ?? "") {
                        GroupDetailsView(title: Constants.animeDemographics[id], group: "genres", id: id, type: .anime)
                    }
                    .buttonStyle(.plain)
                }
            }
            NavigationLink("Studios") {
                StudiosListView()
            }
            .buttonStyle(.plain)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Anime")
    }
}

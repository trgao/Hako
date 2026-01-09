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
                    NavigationLink {
                        GroupDetailsView(title: Constants.animeGenres[id], group: "genres", id: id, type: .anime)
                    } label: {
                        Text(Constants.animeGenres[id] ?? "")
                    }
                    .buttonStyle(.plain)
                }
            }
            Section("Themes") {
                ForEach(Constants.animeThemeKeys, id: \.self) { id in
                    NavigationLink {
                        GroupDetailsView(title: Constants.animeThemes[id], group: "genres", id: id, type: .anime)
                    } label: {
                        Text(Constants.animeThemes[id] ?? "")
                    }
                    .buttonStyle(.plain)
                }
            }
            Section("Demographics") {
                ForEach(Constants.animeDemographicKeys, id: \.self) { id in
                    NavigationLink {
                        GroupDetailsView(title: Constants.animeDemographics[id], group: "genres", id: id, type: .anime)
                    } label: {
                        Text(Constants.animeDemographics[id] ?? "")
                    }
                    .buttonStyle(.plain)
                }
            }
            NavigationLink {
                StudiosListView()
            } label: {
                Text("Studios")
            }
            .buttonStyle(.plain)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Anime")
    }
}

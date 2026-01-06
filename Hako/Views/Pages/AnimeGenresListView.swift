//
//  AnimeGenresListView.swift
//  Hako
//
//  Created by Gao Tianrun on 20/7/25.
//

import SwiftUI

struct AnimeGenresListView: View {
    var body: some View {
        List {
            Section("Genres") {
                ForEach(Array(Constants.animeGenres.keys), id: \.self) { id in
                    NavigationLink {
                        GroupDetailsView(title: Constants.animeGenres[id], urlExtend: "genres=\(String(id))&order_by=popularity&sort=asc", type: .anime)
                    } label: {
                        Text(Constants.animeGenres[id] ?? "")
                    }
                    .buttonStyle(.plain)
                }
            }
            Section("Themes") {
                ForEach(Array(Constants.animeThemes.keys), id: \.self) { id in
                    NavigationLink {
                        GroupDetailsView(title: Constants.animeThemes[id], urlExtend: "genres=\(String(id))&order_by=popularity&sort=asc", type: .anime)
                    } label: {
                        Text(Constants.animeThemes[id] ?? "")
                    }
                    .buttonStyle(.plain)
                }
            }
            Section("Demographics") {
                ForEach(Array(Constants.animeDemographics.keys), id: \.self) { id in
                    NavigationLink {
                        GroupDetailsView(title: Constants.animeDemographics[id], urlExtend: "genres=\(String(id))&order_by=popularity&sort=asc", type: .anime)
                    } label: {
                        Text(Constants.animeDemographics[id] ?? "")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Explore anime")
    }
}

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
                ForEach(Constants.animeGenres) { item in
                    NavigationLink {
                        GroupDetailsView(title: item.name, urlExtend: "genres=\(String(item.id))&order_by=popularity&sort=asc", type: .anime)
                    } label: {
                        Text(item.name)
                    }
                    .buttonStyle(.plain)
                }
            }
            Section("Themes") {
                ForEach(Constants.animeThemes) { item in
                    NavigationLink {
                        GroupDetailsView(title: item.name, urlExtend: "genres=\(String(item.id))&order_by=popularity&sort=asc", type: .anime)
                    } label: {
                        Text(item.name)
                    }
                    .buttonStyle(.plain)
                }
            }
            Section("Demographics") {
                ForEach(Constants.animeDemographics) { item in
                    NavigationLink {
                        GroupDetailsView(title: item.name, urlExtend: "genres=\(String(item.id))&order_by=popularity&sort=asc", type: .anime)
                    } label: {
                        Text(item.name)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Explore anime")
    }
}

//
//  MangaGenresListView.swift
//  Hako
//
//  Created by Gao Tianrun on 20/7/25.
//

import SwiftUI

struct MangaGenresListView: View {
    var body: some View {
        List {
            Section("Genres") {
                ForEach(Constants.mangaGenres) { item in
                    NavigationLink {
                        GroupDetailsView(title: item.name, urlExtend: "genres=\(String(item.id))&order_by=popularity&sort=asc", type: .manga)
                    } label: {
                        Text(item.name)
                    }
                    .buttonStyle(.plain)
                }
            }
            Section("Themes") {
                ForEach(Constants.mangaThemes) { item in
                    NavigationLink {
                        GroupDetailsView(title: item.name, urlExtend: "genres=\(String(item.id))&order_by=popularity&sort=asc", type: .manga)
                    } label: {
                        Text(item.name)
                    }
                    .buttonStyle(.plain)
                }
            }
            Section("Demographics") {
                ForEach(Constants.mangaDemographics) { item in
                    NavigationLink {
                        GroupDetailsView(title: item.name, urlExtend: "genres=\(String(item.id))&order_by=popularity&sort=asc", type: .manga)
                    } label: {
                        Text(item.name)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Explore manga")
    }
}

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
                ForEach(Array(Constants.mangaGenres.keys), id: \.self) { id in
                    NavigationLink {
                        GroupDetailsView(title: Constants.mangaGenres[id], urlExtend: "genres=\(String(id))&order_by=popularity&sort=asc", type: .manga)
                    } label: {
                        Text(Constants.mangaGenres[id] ?? "")
                    }
                    .buttonStyle(.plain)
                }
            }
            Section("Themes") {
                ForEach(Array(Constants.mangaThemes.keys), id: \.self) { id in
                    NavigationLink {
                        GroupDetailsView(title: Constants.mangaThemes[id], urlExtend: "genres=\(String(id))&order_by=popularity&sort=asc", type: .manga)
                    } label: {
                        Text(Constants.mangaThemes[id] ?? "")
                    }
                    .buttonStyle(.plain)
                }
            }
            Section("Demographics") {
                ForEach(Array(Constants.mangaDemographics.keys), id: \.self) { id in
                    NavigationLink {
                        GroupDetailsView(title: Constants.mangaDemographics[id], urlExtend: "genres=\(String(id))&order_by=popularity&sort=asc", type: .manga)
                    } label: {
                        Text(Constants.mangaDemographics[id] ?? "")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Explore manga")
    }
}

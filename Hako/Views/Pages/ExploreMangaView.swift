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
                    NavigationLink {
                        GroupDetailsView(title: Constants.mangaGenres[id], urlExtend: "genres=\(String(id))&order_by=popularity&sort=asc", type: .manga)
                    } label: {
                        Text(Constants.mangaGenres[id] ?? "")
                    }
                    .buttonStyle(.plain)
                }
            }
            Section("Themes") {
                ForEach(Constants.mangaThemeKeys, id: \.self) { id in
                    NavigationLink {
                        GroupDetailsView(title: Constants.mangaThemes[id], urlExtend: "genres=\(String(id))&order_by=popularity&sort=asc", type: .manga)
                    } label: {
                        Text(Constants.mangaThemes[id] ?? "")
                    }
                    .buttonStyle(.plain)
                }
            }
            Section("Demographics") {
                ForEach(Constants.mangaDemographicKeys, id: \.self) { id in
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

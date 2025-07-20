//
//  AnimeGenresListView.swift
//  Hako
//
//  Created by Gao Tianrun on 20/7/25.
//

import SwiftUI

struct AnimeGenresListView: View {
    // Since genres should not change much, I have decided to hard code this instead of relying on Jikan API genres endpoint
    private let genres = [
        MALItem(id: 1, name: "Action"),
        MALItem(id: 2, name: "Adventure"),
        MALItem(id: 5, name: "Avant garde"),
        MALItem(id: 46, name: "Award winning"),
        MALItem(id: 28, name: "Boys love"),
        MALItem(id: 4, name: "Comedy"),
        MALItem(id: 8, name: "Drama"),
        MALItem(id: 10, name: "Fantasy"),
        MALItem(id: 26, name: "Girls love"),
        MALItem(id: 47, name: "Gourmet"),
        MALItem(id: 14, name: "Horror"),
        MALItem(id: 7, name: "Mystery"),
        MALItem(id: 22, name: "Romance"),
        MALItem(id: 24, name: "Sci-Fi"),
        MALItem(id: 36, name: "Slice of life"),
        MALItem(id: 30, name: "Sports"),
        MALItem(id: 37, name: "Supernatural"),
        MALItem(id: 41, name: "Suspense"),
        MALItem(id: 9, name: "Ecchi"),
        MALItem(id: 49, name: "Erotica")
    ]
    private let themes = [
        MALItem(id: 50, name: "Adult cast"),
        MALItem(id: 51, name: "Anthropomorphic"),
        MALItem(id: 52, name: "CGDCT"),
        MALItem(id: 53, name: "Childcare"),
        MALItem(id: 54, name: "Combat sports"),
        MALItem(id: 81, name: "Crossdressing"),
        MALItem(id: 55, name: "Delinquents"),
        MALItem(id: 39, name: "Detective"),
        MALItem(id: 56, name: "Educational"),
        MALItem(id: 57, name: "Gag humour"),
        MALItem(id: 58, name: "Gore"),
        MALItem(id: 35, name: "Harem"),
        MALItem(id: 59, name: "High stakes game"),
        MALItem(id: 13, name: "Historical"),
        MALItem(id: 60, name: "Idols (female)"),
        MALItem(id: 61, name: "Idols (male)"),
        MALItem(id: 62, name: "Isekai"),
        MALItem(id: 63, name: "Iyashikei"),
        MALItem(id: 64, name: "Love polygon"),
        MALItem(id: 65, name: "Magical sex shift"),
        MALItem(id: 66, name: "Mahou shoujo"),
        MALItem(id: 17, name: "Martial arts"),
        MALItem(id: 18, name: "Mecha"),
        MALItem(id: 67, name: "Medical"),
        MALItem(id: 38, name: "Military"),
        MALItem(id: 19, name: "Music"),
        MALItem(id: 6, name: "Mythology"),
        MALItem(id: 68, name: "Organised crime"),
        MALItem(id: 69, name: "Otaku culture"),
        MALItem(id: 20, name: "Parody"),
        MALItem(id: 70, name: "Performing arts"),
        MALItem(id: 71, name: "Pets"),
        MALItem(id: 40, name: "Psychological"),
        MALItem(id: 3, name: "Racing"),
        MALItem(id: 72, name: "Reincarnation"),
        MALItem(id: 73, name: "Reverse harem"),
        MALItem(id: 74, name: "Love status quo"),
        MALItem(id: 21, name: "Samurai"),
        MALItem(id: 23, name: "School"),
        MALItem(id: 75, name: "Showbiz"),
        MALItem(id: 29, name: "Space"),
        MALItem(id: 11, name: "Strategy game"),
        MALItem(id: 31, name: "Super power"),
        MALItem(id: 76, name: "Survival"),
        MALItem(id: 77, name: "Team sports"),
        MALItem(id: 78, name: "Time travel"),
        MALItem(id: 32, name: "Vampire"),
        MALItem(id: 79, name: "Video game"),
        MALItem(id: 80, name: "Visual arts"),
        MALItem(id: 48, name: "Workplace"),
        MALItem(id: 82, name: "Urban fantasy"),
        MALItem(id: 83, name: "Villainess"),
    ]
    private let demographics = [
        MALItem(id: 43, name: "Josei"),
        MALItem(id: 15, name: "Kids"),
        MALItem(id: 42, name: "Seinen"),
        MALItem(id: 25, name: "Shoujo"),
        MALItem(id: 27, name: "Shounen"),
    ]
    
    var body: some View {
        List {
            Section("Genres") {
                ForEach(genres) { item in
                    NavigationLink {
                        GroupDetailsView(title: item.name, urlExtend: "genres=\(String(item.id))&order_by=popularity&sort=asc", type: .anime)
                    } label: {
                        Text(item.name)
                    }
                    .buttonStyle(.plain)
                }
            }
            Section("Themes") {
                ForEach(themes) { item in
                    NavigationLink {
                        GroupDetailsView(title: item.name, urlExtend: "genres=\(String(item.id))&order_by=popularity&sort=asc", type: .anime)
                    } label: {
                        Text(item.name)
                    }
                    .buttonStyle(.plain)
                }
            }
            Section("Demographics") {
                ForEach(demographics) { item in
                    NavigationLink {
                        GroupDetailsView(title: item.name, urlExtend: "genres=\(String(item.id))&order_by=popularity&sort=asc", type: .anime)
                    } label: {
                        Text(item.name)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("Explore anime")
    }
}

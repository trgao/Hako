//
//  ExploreItems.swift
//  Hako
//
//  Created by Gao Tianrun on 17/10/26.
//

import SwiftUI

struct ExploreItems: View {
    @EnvironmentObject private var settings: SettingsManager
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    @ViewBuilder private func getExploreItemDestination(_ item: String) -> some View {
        switch item {
        case "anime": ExploreAnimeView()
        case "manga": ExploreMangaView()
        case "characters": ExploreCharactersView()
        case "people": ExplorePeopleView()
        case "news": NewsListView()
        case "top": TopView()
        default: EmptyView()
        }
    }
    
    @ViewBuilder private func getExploreItemView(_ item: String) -> some View {
        if !settings.replaceTopWithSchedule && item == "top" {
            EmptyView()
        } else {
            ExploreBox(title: item.capitalized, image: Constants.exploreItemIcons[item] ?? "") {
                getExploreItemDestination(item)
            }
        }
    }
    
    var body: some View {
        VStack {
            if dynamicTypeSize <= .xxxLarge {
                ForEach(0..<(settings.exploreItems.count / 2), id: \.self) { index in
                    let item1 = settings.exploreItems[index * 2]
                    let item2 = settings.exploreItems[index * 2 + 1]
                    HStack {
                        getExploreItemView(item1)
                        Spacer()
                        getExploreItemView(item2)
                    }
                    .padding(.horizontal, 17)
                }
                if settings.exploreItems.count % 2 != 0 {
                    let last = settings.exploreItems[settings.exploreItems.count - 1]
                    getExploreItemView(last)
                    .padding(.horizontal, 17)
                    Spacer()
                }
            } else {
                ForEach(settings.exploreItems, id: \.self) { item in
                    getExploreItemView(item)
                    .padding(.horizontal, 17)
                    Spacer()
                }
            }
        }
    }
}

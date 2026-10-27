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
    private var items: [String] {
        settings.exploreItems.filter { settings.replaceTopWithSchedule || $0 != "top" }
    }

    @ViewBuilder private func getExploreItemView(_ item: String) -> some View {
        ExploreBox(item: item, image: Constants.exploreItemIcons[item] ?? "")
    }

    var body: some View {
        VStack {
            if dynamicTypeSize <= .xxxLarge {
                ForEach(0..<(items.count / 2), id: \.self) { index in
                    let item1 = items[index * 2]
                    let item2 = items[index * 2 + 1]
                    HStack {
                        getExploreItemView(item1)
                        Spacer()
                        getExploreItemView(item2)
                    }
                }
                if items.count % 2 != 0 {
                    let last = items[items.count - 1]
                    getExploreItemView(last)
                }
            } else {
                ForEach(items, id: \.self) { item in
                    getExploreItemView(item)
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 17)
    }
}

//
//  CustomiseExplore.swift
//  Hako
//
//  Created by Gao Tianrun on 17/10/26.
//

import SwiftUI

struct CustomiseExplore: View {
    @EnvironmentObject private var settings: SettingsManager
    private var availableItems: [String] {
        Constants.exploreItems.filter { !settings.exploreItems.contains($0) }
    }

    var body: some View {
        List {
            Section("Displayed items") {
                ForEach(settings.exploreItems, id: \.self) { item in
                    if !settings.replaceTopWithSchedule && item == "top" {
                        EmptyView()
                    } else {
                        Label(item.capitalized, systemImage: Constants.exploreItemIcons[item] ?? "")
                    }
                }
                .onMove { source, destination in
                    settings.exploreItems.move(
                        fromOffsets: source,
                        toOffset: destination
                    )
                }
                .onDelete { offsets in
                    settings.exploreItems.remove(atOffsets: offsets)
                }
            }

            Section("Available items") {
                ForEach(availableItems, id: \.self) { item in
                    if !settings.replaceTopWithSchedule && item == "top" {
                        EmptyView()
                    } else {
                        HStack {
                            Label(item.capitalized, systemImage: Constants.exploreItemIcons[item] ?? "")
                            Spacer()
                            Button {
                                settings.exploreItems.append(item)
                            } label: {
                                Image(systemName: "plus.circle")
                                    .foregroundStyle(.tint)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Add \(item)")
                        }
                    }
                }
            }
        }
        .id(settings.exploreItems.count)
        .navigationTitle("Customise explore items")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            EditButton()
        }
    }
}

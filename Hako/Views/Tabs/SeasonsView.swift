//
//  SeasonsView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

struct SeasonsView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller = SeasonsViewController()
    @State private var isRefresh = false
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150), alignment: .top),
    ]
    private let options = [
        ("Winter", "winter"),
        ("Spring", "spring"),
        ("Summer", "summer"),
        ("Fall", "fall"),
    ]
    let networker = NetworkManager.shared
    
    @ViewBuilder private func SeasonView(_ season: String, _ seasonItems: [MALListAnime], _ seasonContinuingItems: [MALListAnime]) -> some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(Array(seasonItems.enumerated()), id: \.1.id) { index, item in
                    AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large)
                        .task {
                            await controller.loadMoreIfNeeded(index: index)
                        }
                }
                if seasonItems.count % 2 != 0 {
                    AnimeGridItem(id: 0, title: nil, enTitle: nil, imageUrl: nil)
                        .hidden()
                }
                if !controller.getCurrentSeasonCanLoadMore() && !controller.isSeasonContinuingEmpty() && !settings.hideContinuingSeries {
                    Text("Continuing")
                        .padding(.bottom, 10)
                        .padding([.top, .horizontal], 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .bold()
                        .font(.title2)
                    Rectangle()
                        .frame(height: 20)
                        .hidden()
                    ForEach(seasonContinuingItems) { item in
                        AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 45)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if controller.isLoadingError && controller.isSeasonEmpty() {
                    ErrorView(refresh: { await controller.refresh() })
                } else if controller.season == "winter" {
                    SeasonView("winter", controller.winterItems, controller.winterContinuingItems)
                } else if controller.season == "spring" {
                    SeasonView("spring", controller.springItems, controller.springContinuingItems)
                } else if controller.season == "summer" {
                    SeasonView("summer", controller.summerItems, controller.summerContinuingItems)
                } else if controller.season == "fall" {
                    SeasonView("fall", controller.fallItems, controller.fallContinuingItems)
                }
                TabPicker(selection: $controller.season, options: options, refresh: {
                    if controller.shouldRefresh() {
                        await controller.refresh()
                    }
                })
                    .disabled(controller.getCurrentSeasonLoading())
                if controller.getCurrentSeasonLoading() {
                    LoadingView()
                }
                if controller.isSeasonEmpty() && !controller.getCurrentSeasonLoading() && !controller.isLoadingError {
                    VStack {
                        Image(systemName: "calendar")
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text("Nothing found")
                            .bold()
                    }
                }
            }
            .navigationTitle(controller.season.capitalized)
            .task(id: isRefresh) {
                if controller.shouldRefresh() || isRefresh {
                    await controller.refresh()
                    isRefresh = false
                }
            }
            .refreshable {
                isRefresh = true
            }
            .toolbar {
                Menu {
                    Picker(selection: $controller.year, label: EmptyView()) {
                        ForEach((1917...controller.currentYear + 1).reversed(), id: \.self) { year in
                            Text(String(year)).tag(String(year))
                        }
                    }
                    .onChange(of: controller.year) {
                        Task {
                            await controller.refresh(true)
                        }
                    }
                } label: {
                    Button(String(controller.year)) {}
                        .buttonStyle(.borderedProminent)
                }
                .disabled(controller.getCurrentSeasonLoading())
            }
        }
    }
}

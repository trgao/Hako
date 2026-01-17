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
    @State private var isLink = false
    @Binding private var id: UUID
    @Binding private var year: Int?
    @Binding private var season: SeasonEnum?
    let networker = NetworkManager.shared
    
    init(id: Binding<UUID>, year: Binding<Int?>, season: Binding<SeasonEnum?>) {
        self._id = id
        self._year = year
        self._season = season
    }
    
    @ViewBuilder private func SeasonView(_ seasonItems: [MALListAnime], _ seasonContinuingItems: [MALListAnime]) -> some View {
        ScrollView {
            VStack {
                LazyVGrid(columns: Constants.columns) {
                    ForEach(Array(seasonItems.enumerated()), id: \.1.id) { index, item in
                        AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large, anime: item.node)
                            .onAppear {
                                Task {
                                    await controller.loadMoreIfNeeded(index: index)
                                }
                            }
                    }
                }
                if !controller.getCurrentSeasonCanLoadMore() && !controller.isSeasonContinuingEmpty() && !settings.hideContinuingSeries {
                    Text("Continuing")
                        .padding(.bottom, 10)
                        .padding([.top, .horizontal], 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .bold()
                        .font(.title2)
                    LazyVGrid(columns: Constants.columns) {
                        ForEach(seasonContinuingItems) { item in
                            AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large, anime: item.node)
                        }
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
                } else if controller.season == .winter {
                    SeasonView(controller.winterItems, controller.winterContinuingItems)
                } else if controller.season == .spring {
                    SeasonView(controller.springItems, controller.springContinuingItems)
                } else if controller.season == .summer {
                    SeasonView(controller.summerItems, controller.summerContinuingItems)
                } else if controller.season == .fall {
                    SeasonView(controller.fallItems, controller.fallContinuingItems)
                }
                TabPicker(selection: $controller.season, options: [("Winter", SeasonEnum.winter), ("Spring", SeasonEnum.spring), ("Summer", SeasonEnum.summer), ("Fall", SeasonEnum.fall)])
                    .onChange(of: controller.season) {
                        if controller.shouldRefresh() && !isLink {
                            Task {
                                await controller.refresh()
                            }
                        }
                    }
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
            .navigationTitle(controller.season.rawValue.capitalized)
            .task(id: isRefresh) {
                if !isLink && (controller.shouldRefresh() || isRefresh) {
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
                        ForEach((1917...Constants.currentYear + 1).reversed(), id: \.self) { year in
                            Text(String(year)).tag(String(year))
                        }
                    }
                    .onChange(of: controller.year) {
                        if !isLink {
                            Task {
                                await controller.refresh(true)
                            }
                        }
                    }
                } label: {
                    if #available (iOS 26.0, *) {
                        Button(String(controller.year)) {}
                            .padding()
                    } else {
                        Button(String(controller.year)) {}
                            .buttonStyle(.borderedProminent)
                    }
                }
                .disabled(controller.getCurrentSeasonLoading())
            }
        }
        .id(id)
        .onChange(of: id) {
            Task {
                if let year = year, let season = season {
                    isLink = true
                    controller.year = year
                    controller.season = season
                    await controller.refresh(true)
                    isLink = false
                }
                year = nil
                season = nil
            }
        }
    }
}

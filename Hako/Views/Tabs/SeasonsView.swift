//
//  SeasonsView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

struct SeasonsView: View {
    @Environment(\.screenRatio) private var screenRatio
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller = SeasonsViewController()
    @State private var isRefresh = false
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
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150 * screenRatio), spacing: 5, alignment: .top)]) {
                    ForEach(Array(seasonItems.enumerated()), id: \.1.id) { index, item in
                        AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large, anime: item.node)
                    }
                }
                if !controller.isSeasonContinuingEmpty() && !settings.hideContinuingSeries {
                    Text("Continuing")
                        .padding(.bottom, 10)
                        .padding([.top, .horizontal], 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .bold()
                        .font(.title2)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150 * screenRatio), spacing: 5, alignment: .top)]) {
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
                if controller.loadingState == .error && controller.isSeasonEmpty() {
                    ErrorView(refresh: { await controller.refresh() })
                } else if controller.loadingState == .idle && controller.isSeasonEmpty() {
                    VStack {
                        Image(systemName: "calendar")
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text("Nothing found")
                            .bold()
                    }
                } else if controller.season == .winter {
                    SeasonView(controller.winterItems, controller.winterContinuingItems)
                } else if controller.season == .spring {
                    SeasonView(controller.springItems, controller.springContinuingItems)
                } else if controller.season == .summer {
                    SeasonView(controller.summerItems, controller.summerContinuingItems)
                } else if controller.season == .fall {
                    SeasonView(controller.fallItems, controller.fallContinuingItems)
                }
                TabPicker(selection: $controller.season, options: Constants.seasons.map { ($0.rawValue.capitalized, $0) })
                    .onChange(of: controller.season) {
                        if year == nil && season == nil && controller.shouldRefresh() {
                            // Loading state is changed here to prevent brief flickering of nothing found view
                            controller.loadingState = .loading
                            Task {
                                await controller.refresh()
                            }
                        }
                    }
                    .disabled(controller.loadingState == .loading)
                if controller.loadingState == .loading {
                    LoadingView()
                }

            }
            .navigationTitle(controller.season.rawValue.capitalized)
            .refreshable {
                isRefresh = true
            }
            .task(id: isRefresh) {
                if year == nil && season == nil && (controller.shouldRefresh() || isRefresh) {
                    await controller.refresh()
                    isRefresh = false
                }
            }
            .toolbar {
                Menu {
                    Picker("Year", selection: $controller.year) {
                        ForEach((1917...Constants.currentYear + 1).reversed(), id: \.self) { year in
                            Text(String(year)).tag(String(year))
                        }
                    }
                    .onChange(of: controller.year) {
                        if year == nil && season == nil {
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
                .disabled(controller.loadingState == .loading)
            }
        }
        .id(id)
        .task(id: id) {
            if let year = year, let season = season {
                controller.year = year
                controller.season = season
                await controller.refresh(true)
            }
            year = nil
            season = nil
        }
    }
}

//
//  SeasonsView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

struct SeasonsView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.screenRatio) private var screenRatio
    @Environment(Router.self) private var router
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller = SeasonsViewController()
    @State private var isInit = false
    @State private var isRefresh = false
    @Binding private var id: UUID?
    @Binding private var isResetSeasons: Bool
    @Binding private var year: Int?
    @Binding private var season: SeasonEnum?
    @Binding private var pickerSeason: SeasonEnum
    @Binding private var pickerDisabled: Bool
    private let networker = NetworkManager.shared

    init(id: Binding<UUID?> = .constant(nil), isResetSeasons: Binding<Bool>, year: Binding<Int?>, season: Binding<SeasonEnum?>, pickerSeason: Binding<SeasonEnum>, pickerDisabled: Binding<Bool>) {
        self._id = id
        self._isResetSeasons = isResetSeasons
        self._year = year
        self._season = season
        self._pickerSeason = pickerSeason
        self._pickerDisabled = pickerDisabled
    }

    private func SeasonView(_ seasonItems: [MALListAnime], _ seasonContinuingItems: [MALListAnime], _ width: CGFloat) -> some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150 * screenRatio), spacing: 5, alignment: .top)]) {
                ForEach(Array(seasonItems.enumerated()), id: \.1.id) { _, item in
                    AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, jaTitle: item.node.alternativeTitles?.ja, imageUrl: item.node.mainPicture?.large, anime: item.node)
                }
                if !settings.hideContinuingSeries && !seasonContinuingItems.isEmpty {
                    // To make it appear like a section title, SwiftUI section is buggy with LazyVGrid
                    Group {
                        let numberOfColumns = max(2, Int((width - 5) / (150 * screenRatio + 5)))
                        ForEach(0..<((numberOfColumns - seasonItems.count % numberOfColumns) % numberOfColumns), id: \.self) { id in
                            Color.clear.id("frontbuffer\(id)")
                        }
                        Text("Continuing")
                            .padding(.bottom, 10)
                            .padding([.top, .horizontal], 20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .bold()
                            .font(.title2)
                        ForEach(0..<(numberOfColumns - 1), id: \.self) { id in
                            Color.clear.id("endbuffer\(id)")
                        }
                    }
                    ForEach(seasonContinuingItems) { item in
                        AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, jaTitle: item.node.alternativeTitles?.ja, imageUrl: item.node.mainPicture?.large, anime: item.node)
                    }
                }
            }
            .padding(10)
            .padding(.bottom, 35)
        }
        .id(controller.sort)
    }

    private var nothingFoundView: some View {
        VStack {
            Image(systemName: "calendar")
                .resizable()
                .frame(width: 40, height: 40)
            Text("No anime")
                .bold()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private var tabPicker: some View {
        TabPicker(selection: $controller.season, options: Constants.seasons.map { ($0.rawValue.capitalized, $0) })
            .onChange(of: controller.season) {
                if year == nil && season == nil && controller.shouldRefresh() {
                    // Loading state is changed here to prevent brief flickering of nothing found view
                    controller.loadingState = .loading
                    Task {
                        await controller.refresh()
                        // Reset navigation stack so that large navigation title can display if season is empty
                        router.popToRoot()
                    }
                }
            }
            .disabled(controller.loadingState == .loading)
    }

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            GeometryReader { geometry in
                ZStack {
                    if controller.isSeasonEmpty() {
                        if controller.loadingState == .loading {
                            LoadingGrid()
                        } else if controller.loadingState == .error {
                            ErrorView(refresh: { await controller.refresh() })
                        } else if controller.loadingState == .idle {
                            nothingFoundView
                        }
                    } else if controller.season == .winter {
                        SeasonView(controller.winterItems, controller.winterContinuingItems, geometry.size.width)
                    } else if controller.season == .spring {
                        SeasonView(controller.springItems, controller.springContinuingItems, geometry.size.width)
                    } else if controller.season == .summer {
                        SeasonView(controller.summerItems, controller.summerContinuingItems, geometry.size.width)
                    } else if controller.season == .fall {
                        SeasonView(controller.fallItems, controller.fallContinuingItems, geometry.size.width)
                    }
                    if #unavailable (iOS 26.2) {
                        tabPicker
                    } else if horizontalSizeClass != .compact {
                        tabPicker
                    }
                    if isRefresh {
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
                    ToolbarItem(placement: .topBarLeading) {
                        Menu {
                            Picker("Sort", selection: $controller.sort) {
                                ForEach(Constants.seasonSorts, id: \.self) { sort in
                                    Label(sort.toString(), systemImage: sort.toIcon()).tag(sort)
                                }
                            }
                            .pickerStyle(.inline)
                            .labelsVisibility(.visible)
                        } label: {
                            Label("Menu", systemImage: "arrow.up.arrow.down.circle")
                                .labelStyle(.iconOnly)
                        }
                        .disabled(controller.loadingState == .loading)
                        .onChange(of: controller.sort) {
                            controller.sortItems()
                        }
                    }
                    if !settings.replaceTopWithSchedule && !settings.hideSchedule {
                        ToolbarItem(placement: .topBarLeading) {
                            NavigationLink(value: Route.screen(.schedule)) {
                                Label("Schedule", systemImage: "calendar.badge.clock")
                                    .labelStyle(.iconOnly)
                            }
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Picker("Year", selection: $controller.year) {
                                ForEach((1917...Constants.currentYear + 1).reversed(), id: \.self) { year in
                                    Text(String(year)).tag(String(year))
                                }
                            }
                            .pickerStyle(.inline)
                            .onChange(of: controller.year) {
                                if year == nil && season == nil {
                                    Task {
                                        await controller.refresh(true)
                                        // Reset navigation stack so that large navigation title can display if season is empty
                                        router.popToRoot()
                                    }
                                }
                            }
                        } label: {
                            if #available (iOS 26.0, *) {
                                Button(String(controller.year)) {}
                                    .padding()
                            } else {
                                Button(String(controller.year)) {}
                                    .buttonStyle(.bordered)
                            }
                        }
                        .disabled(controller.loadingState == .loading)
                    }
                }
                .onChange(of: isResetSeasons) {
                    if isResetSeasons {
                        controller.year = Constants.currentYear
                        controller.season = Constants.currentSeason
                        isResetSeasons = false
                    }
                }
            }
            .task(id: id) {
                if let year, let season {
                    controller.year = year
                    controller.season = season
                    pickerSeason = season
                }
                if !isInit {
                    controller.sort = settings.getSeasonSort()
                }
                year = nil
                season = nil
                isInit = true
            }
            .navigationDestinations()
        }
        .onChange(of: settings.replaceTopWithSchedule) {
            if settings.replaceTopWithSchedule {
                router.popToRoot()
            }
        }
        .onChange(of: pickerSeason) {
            controller.season = pickerSeason
            if year == nil && season == nil && controller.shouldRefresh() {
                // Loading state is changed here to prevent brief flickering of nothing found view
                controller.loadingState = .loading
                Task {
                    await controller.refresh()
                    // Reset navigation stack so that large navigation title can display if season is empty
                    router.popToRoot()
                }
            }
        }
        .onChange(of: controller.loadingState) {
            pickerDisabled = controller.loadingState == .loading
        }
    }
}

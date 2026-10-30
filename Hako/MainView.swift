//
//  ContentView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import LocalAuthentication

struct MainView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var networker = NetworkManager.shared
    @State private var isInit = false
    @State private var id: UUID? // To retrigger task for deep link if view was on same page
    @State private var tab = 0
    @State private var isUnlocked = false
    @State private var isAuthenticationError = false
    @State private var url: URL?

    // Schedule tab
    @State private var scheduleRouter = Router()

    // Top tab
    @State private var topRouter = Router()
    @State private var topType: TypeEnum?
    @State private var animeRanking: RankingEnum?
    @State private var mangaRanking: RankingEnum?

    // Seasons tab
    @State private var seasonsRouter = Router()
    @State private var isResetSeasons = false
    @State private var year: Int?
    @State private var season: SeasonEnum?
    @State private var pickerSeason = Constants.currentSeason
    @State private var seasonPickerDisabled = false

    // Explore tab
    @State private var exploreRouter = Router()
    @State private var isSearchPresented = false
    @State private var urlSearchText: String?
    @State private var pickerSearchType = SearchEnum.anime

    // My list tab
    @State private var myListRouter = Router()
    @State private var listType: TypeEnum?
    @State private var animeStatus: StatusEnum?
    @State private var animeSort: SortEnum?
    @State private var mangaStatus: StatusEnum?
    @State private var mangaSort: SortEnum?
    @State private var pickerType: TypeEnum = .anime
    @State private var pickerAnimeStatus: StatusEnum = .watching
    @State private var pickerMangaStatus: StatusEnum = .reading
    @State private var myListPickerDisabled = false

    // Settings tab
    @State private var settingsRouter = Router()

    private var tabBinding: Binding<Int> {
        Binding(
            get: {
                self.tab
            },
            set: {
                if $0 == self.tab {
                    if self.tab == 0 {
                        if settings.replaceTopWithSchedule {
                            scheduleRouter.popToRoot()
                        } else {
                            topRouter.popToRoot()
                        }
                    } else if self.tab == 1 {
                        if seasonsRouter.isRoot {
                            isResetSeasons = true
                            pickerSeason = Constants.currentSeason
                        } else {
                            seasonsRouter.popToRoot()
                        }
                    } else if self.tab == 2 {
                        if exploreRouter.isRoot {
                            isSearchPresented.toggle()
                        } else {
                            exploreRouter.popToRoot()
                        }
                    } else if self.tab == 3 {
                        if myListRouter.isRoot {
                            if pickerType == .anime {
                                pickerAnimeStatus = settings.getAnimeStatus()
                            } else if pickerType == .manga {
                                pickerMangaStatus = settings.getMangaStatus()
                            }
                        } else {
                            myListRouter.popToRoot()
                        }
                    } else if self.tab == 4 {
                        settingsRouter.popToRoot()
                    }
                }
                self.tab = $0
            }
        )
    }

    private var currentRouter: Router {
        switch tab {
        case 1: seasonsRouter
        case 2: exploreRouter
        case 3: myListRouter
        case 4: settingsRouter
        default: settings.replaceTopWithSchedule ? scheduleRouter : topRouter
        }
    }

    private var showSeasonsTabViewBottomAccessory: Bool {
        tabBinding.wrappedValue == 1 && seasonsRouter.isRoot
    }

    private var showExploreTabViewBottomAccessory: Bool {
        tabBinding.wrappedValue == 2 && exploreRouter.isRoot && isSearchPresented
    }

    private var showMyListTabViewBottomAccessory: Bool {
        tabBinding.wrappedValue == 3 && networker.isSignedIn && myListRouter.isRoot && settings.useStatusTabBar
    }

    private var showUserListTabViewBottomAccessory: Bool {
        (tabBinding.wrappedValue == 0 && (settings.replaceTopWithSchedule ? scheduleRouter.isUserListPresented : topRouter.isUserListPresented)) || (tabBinding.wrappedValue == 1 && seasonsRouter.isUserListPresented) || (tabBinding.wrappedValue == 2 && exploreRouter.isUserListPresented) || (tabBinding.wrappedValue == 3 && myListRouter.isUserListPresented) || (tabBinding.wrappedValue == 4 && settingsRouter.isUserListPresented)
    }

    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).adjustsFontSizeToFitWidth = true
    }

    // Handle FaceID
    private func authenticate() {
        guard settings.useFaceID else {
            return
        }

        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            isUnlocked = true // no passcode means nothing to protect
            return
        }

        Task { @MainActor in
            do {
                isUnlocked = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock Hako")
            } catch {
                isAuthenticationError = true
            }
        }
    }

    // Handle deep links
    private func handleUrl(url: URL) {
        let FIREBASE_LINK = Bundle.main.infoDictionary?["FIREBASE_LINK"] as? String
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }

        // Resolve page name
        let page: String
        if url.scheme == "hako", let host = components.host {
            page = host.lowercased()
        } else if url.host == FIREBASE_LINK {
            page = String(components.path.dropFirst()).lowercased()
        } else {
            return
        }

        self.isInit = true
        self.id = UUID()
        self.url = nil

        // Shared parsing
        let type = components.value("type").flatMap(TypeEnum.init(rawValue:))
        let itemId = components.value("id").flatMap(Int.init)
        let user = components.value("user")
        let isOwnUser = user.map { $0.lowercased() == networker.user?.name?.lowercased() } ?? false

        func genreName(id: Int, type: TypeEnum) -> String? {
            switch type {
            case .anime:
                Constants.animeGenres[id] ?? Constants.animeThemes[id] ?? Constants.animeDemographics[id]
            case .manga:
                Constants.mangaGenres[id] ?? Constants.mangaThemes[id] ?? Constants.mangaDemographics[id]
            default:
                nil
            }
        }

        switch page {
        case "top":
            guard let topType = type else {
                return
            }

            let ranking = components.value("ranking").flatMap(RankingEnum.init(rawValue:))
            let animeRanking = topType == .anime ? ranking : nil
            let mangaRanking = topType == .manga ? ranking : nil

            if settings.replaceTopWithSchedule {
                tab = Constants.exploreTab
                exploreRouter.restartWith(Route.topDetail(TopDetail(id: id, type: type, animeRanking: animeRanking, mangaRanking: mangaRanking)))
                isSearchPresented = false
            } else {
                tab = Constants.topTab
                topRouter.popToRoot()
                self.topType = topType
                self.animeRanking = animeRanking
                self.mangaRanking = mangaRanking
            }

        case "seasons":
            tab = Constants.seasonsTab
            seasonsRouter.popToRoot()
            if let year = components.value("year").flatMap(Int.init), year >= 1917 && year <= Constants.currentYear + 1, let season = components.value("season").flatMap(SeasonEnum.init(rawValue:)) {
                self.year = year
                self.season = season
            }

        case "explore":
            tab = Constants.exploreTab
            exploreRouter.popToRoot()
            if let text = components.value("query") {
                isSearchPresented = true
                urlSearchText = text
            } else if let type = components.value("type"), let screen = Screen(rawValue: type) {
                isSearchPresented = false
                exploreRouter.push(Route.screen(screen))
            }

        case "mylist":
            let status = components.value("status").flatMap(StatusEnum.init(rawValue:))
            let sort = components.value("sort").flatMap(SortEnum.init(rawValue:))
            let animeStatus = type == .anime ? status : nil
            let animeSort = type == .anime ? sort : nil
            let mangaStatus = type == .manga ? status : nil
            let mangaSort = type == .manga ? sort : nil

            if let user, !isOwnUser {
                tab = Constants.exploreTab
                exploreRouter.restartWith(Route.userList(UserList(username: user, id: id, type: type, animeStatus: animeStatus, animeSort: animeSort, mangaStatus: mangaStatus, mangaSort: mangaSort)))
                isSearchPresented = false
            } else {
                tab = Constants.myListTab
                myListRouter.popToRoot()
                self.listType = type
                self.animeStatus = animeStatus
                self.animeSort = animeSort
                self.mangaStatus = mangaStatus
                self.mangaSort = mangaSort
            }

        case "settings":
            tab = Constants.settingsTab
            settingsRouter.popToRoot()

        case "news":
            tab = Constants.exploreTab
            exploreRouter.restartWith(Route.screen(.news))
            isSearchPresented = false

        case "genre":
            guard let itemId, let type, let name = genreName(id: itemId, type: type) else {
                return
            }

            tab = Constants.exploreTab
            exploreRouter.restartWith(Route.groupDetail(GroupDetail(id: itemId, name: name, type: type, group: "genres")))
            isSearchPresented = false

        case "anime", "manga", "character", "person":
            guard let itemId, let viewType = ViewTypeEnum(rawValue: page) else {
                return
            }

            tab = Constants.exploreTab
            exploreRouter.restartWith(Route.viewItem(ViewItem(type: viewType, id: itemId)))
            isSearchPresented = false

        case "producer", "magazine":
            guard let itemId else {
                return
            }

            tab = Constants.exploreTab
            exploreRouter.restartWith(Route.groupDetail(GroupDetail(id: itemId, name: components.value("name") ?? "", type: page == "producer" ? .anime : .manga, group: "\(page)s")))
            isSearchPresented = false
        case "profile":
            guard let user else {
                return
            }

            if isOwnUser {
                tab = Constants.settingsTab
                settingsRouter.restartWith(Route.screen(.profile))
            } else {
                tab = Constants.exploreTab
                exploreRouter.restartWith(Route.userList(UserList(username: user)))
                isSearchPresented = false
            }

        default:
            break
        }
    }

    private var tabs: some View {
        TabView(selection: tabBinding) {
            if settings.replaceTopWithSchedule {
                Tab("Schedule", systemImage: "calendar.badge.clock", value: 0) {
                    ScheduleView(isTab: true)
                        .environment(scheduleRouter)
                }
            } else {
                Tab("Top", systemImage: "medal", value: 0) {
                    TopView(id: $id, type: $topType, animeRanking: $animeRanking, mangaRanking: $mangaRanking)
                        .environment(topRouter)
                }
            }
            Tab("Seasons", systemImage: "calendar", value: 1) {
                SeasonsView(id: $id, isResetSeasons: $isResetSeasons, year: $year, season: $season, pickerSeason: $pickerSeason, pickerDisabled: $seasonPickerDisabled)
                    .environment(seasonsRouter)
            }
            Tab("Explore", systemImage: "magnifyingglass", value: 2) {
                ExploreView(isPresented: $isSearchPresented, urlSearchText: $urlSearchText, pickerType: $pickerSearchType)
                    .environment(exploreRouter)
            }
            if !settings.useWithoutAccount {
                Tab("My list", systemImage: "list.bullet", value: 3) {
                    MyListView(id: $id, type: $listType, animeStatus: $animeStatus, animeSort: $animeSort, mangaStatus: $mangaStatus, mangaSort: $mangaSort, pickerType: $pickerType, pickerAnimeStatus: $pickerAnimeStatus, pickerMangaStatus: $pickerMangaStatus, pickerDisabled: $myListPickerDisabled)
                        .environment(myListRouter)
                }
            }
            Tab("Settings", systemImage: "gear", value: 4) {
                SettingsView()
                    .environment(settingsRouter)
                    .onChange(of: settings.useFaceID) {
                        isUnlocked = true
                    }
            }
        }
        .onAppear {
            guard !isInit else {
                return
            }

            isInit = true
            tab = settings.openLastClosedTab ? settings.savedTab : settings.defaultView
        }
        .onChange(of: tab) {
            settings.savedTab = tab
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabViewSidebarBottomBar {
            if networker.isSignedIn, let user = networker.user {
                Button {
                    tab = 4
                    settingsRouter.restartWith(Route.screen(.profile))
                } label: {
                    HStack {
                        ProfileImage(imageUrl: user.picture)
                            .scaleEffect(0.7)
                        Text(user.name ?? "")
                            .font(.title3)
                            .bold()
                    }
                    .padding(.horizontal, 10)
                    .id(networker.user?.picture)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder private var tabViewBottomAccessory: some View {
        @Bindable var router = currentRouter
        if showSeasonsTabViewBottomAccessory {
            TabPicker(selection: $pickerSeason, options: Constants.seasons.map { ($0.rawValue.capitalized, $0) })
                .disabled(seasonPickerDisabled)
        } else if showExploreTabViewBottomAccessory {
            TabPicker(selection: $pickerSearchType, options: Constants.searchTypes.map { ($0.rawValue.capitalized, $0) })
        } else if showMyListTabViewBottomAccessory {
            if pickerType == .anime {
                UserListStatusPicker(selection: $pickerAnimeStatus, options: Constants.animeStatuses, isLoading: myListPickerDisabled)
                    .scrollClipDisabled()
            } else if pickerType == .manga {
                UserListStatusPicker(selection: $pickerMangaStatus, options: Constants.mangaStatuses, isLoading: myListPickerDisabled)
            }
        } else if showUserListTabViewBottomAccessory {
            if router.pickerType == .anime {
                UserListStatusPicker(selection: $router.pickerAnimeStatus, options: Constants.animeStatuses, isLoading: router.pickerDisabled)
            } else if router.pickerType == .manga {
                UserListStatusPicker(selection: $router.pickerMangaStatus, options: Constants.mangaStatuses, isLoading: router.pickerDisabled)
            }
        }
    }

    var body: some View {
        ZStack {
            let isLocked = settings.useFaceID && !isUnlocked
            Group {
                if #available (iOS 26.2, *), horizontalSizeClass == .compact {
                    tabs
                        .tabBarMinimizeBehavior(.onScrollDown)
                        .tabViewBottomAccessory(isEnabled: showSeasonsTabViewBottomAccessory || showExploreTabViewBottomAccessory || showMyListTabViewBottomAccessory || showUserListTabViewBottomAccessory) {
                            tabViewBottomAccessory
                        }
                } else {
                    tabs
                }
            }
            .opacity(isLocked ? 0 : 1)
            .disabled(isLocked)
            .accessibilityHidden(isLocked)
            if isLocked {
                VStack {
                    Text("Hako is locked")
                        .font(.title)
                        .bold()
                    Button("Unlock") {
                        authenticate()
                    }
                    .prominentButtonStyle()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(.background)
            }
        }
        .dynamicTypeSize(settings.dynamicType ? dynamicTypeSize : .large)
        .onAppear {
            authenticate()
        }
        .onChange(of: scenePhase) { prev, cur in
            if cur == .background {
                isUnlocked = false
            } else if prev == .background {
                authenticate()
            }
        }
        .onOpenURL(perform: handleUrl)
        .handleOpenURLInApp(url: $url)
    }
}

private extension URLComponents {
    func value(_ name: String) -> String? {
        queryItems?.first(where: { $0.name == name })?.value
    }
}

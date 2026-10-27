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
        (tabBinding.wrappedValue == 0 && ((settings.replaceTopWithSchedule && scheduleRouter.isUserListPresented) || topRouter.isUserListPresented)) || (tabBinding.wrappedValue == 1 && seasonsRouter.isUserListPresented) || (tabBinding.wrappedValue == 2 && exploreRouter.isUserListPresented) || (tabBinding.wrappedValue == 3 && myListRouter.isUserListPresented) || (tabBinding.wrappedValue == 4 && settingsRouter.isUserListPresented)
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

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Face ID is required to lock app"

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
                if success {
                    isUnlocked = true
                } else {
                    isAuthenticationError = true
                }
            }
        } else {
            isAuthenticationError = true
        }
    }

    private func genreName(id: Int, type: TypeEnum) -> String? {
        switch type {
        case .anime:
            Constants.animeGenres[id] ?? Constants.animeThemes[id] ?? Constants.animeDemographics[id]
        case .manga:
            Constants.mangaGenres[id] ?? Constants.mangaThemes[id] ?? Constants.mangaDemographics[id]
        default:
            nil
        }
    }

    // Handle deep links
    private func handleUrl(url: URL) {
        let FIREBASE_LINK = Bundle.main.infoDictionary?["FIREBASE_LINK"] as? String
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }

        self.id = UUID()

        var page: String
        // Check for correct urls
        if url.scheme == "hako", let host = components.host {
            page = host.lowercased()
        } else if url.host == FIREBASE_LINK {
            page = String(components.path.dropFirst()).lowercased()
        } else {
            return
        }

        self.url = nil
        if page == "top" {
            var topType: TypeEnum?
            var animeRanking: RankingEnum?
            var mangaRanking: RankingEnum?
            if let type = components.queryItems?.first(where: { $0.name == "type" })?.value {
                if type == "anime" {
                    topType = .anime
                    if let rankingText = components.queryItems?.first(where: { $0.name == "ranking" })?.value, let ranking = RankingEnum(rawValue: rankingText) {
                        animeRanking = ranking
                    }
                } else if type == "manga" {
                    topType = .manga
                    if let rankingText = components.queryItems?.first(where: { $0.name == "ranking" })?.value, let ranking = RankingEnum(rawValue: rankingText) {
                        mangaRanking = ranking
                    }
                }
            }
            if settings.replaceTopWithSchedule {
                tab = 2
                exploreRouter.restartWith(TopDetail(id: id, type: topType, animeRanking: animeRanking, mangaRanking: mangaRanking))
                isSearchPresented = false
            } else {
                tab = 0
                topRouter.popToRoot()
                self.topType = topType
                self.animeRanking = animeRanking
                self.mangaRanking = mangaRanking
            }
        } else if page == "seasons" {
            tab = 1
            seasonsRouter.popToRoot()
            if let yearText = components.queryItems?.first(where: { $0.name == "year" })?.value, let yearInt = Int(yearText), let seasonText = components.queryItems?.first(where: { $0.name == "season" })?.value, let seasonEnum = SeasonEnum(rawValue: seasonText), yearInt >= 1917 && yearInt <= Constants.currentYear + 1 {
                year = yearInt
                season = seasonEnum
            }
        } else if page == "explore" {
            tab = 2
            exploreRouter.popToRoot()
            if let text = components.queryItems?.first(where: { $0.name == "query" })?.value {
                isSearchPresented = true
                urlSearchText = text
            } else if let type = components.queryItems?.first(where: { $0.name == "type" })?.value {
                isSearchPresented = false
                exploreRouter.push(type)
            }
        } else if page == "mylist" {
            var itemType: TypeEnum?
            var animeStatus: StatusEnum?
            var animeSort: SortEnum?
            var mangaStatus: StatusEnum?
            var mangaSort: SortEnum?
            if let type = components.queryItems?.first(where: { $0.name == "type" })?.value {
                if type == "anime" {
                    itemType = .anime
                    if let statusText = components.queryItems?.first(where: { $0.name == "status" })?.value, let status = StatusEnum(rawValue: statusText), status != .reading && status != .planToRead {
                        animeStatus = status
                    }
                    if let sortText = components.queryItems?.first(where: { $0.name == "sort" })?.value, let sort = SortEnum(rawValue: sortText) {
                        animeSort = sort
                    }
                } else if type == "manga" {
                    itemType = .manga
                    if let statusText = components.queryItems?.first(where: { $0.name == "status" })?.value, let status = StatusEnum(rawValue: statusText), status != .watching && status != .planToWatch {
                        mangaStatus = status
                    }
                    if let sortText = components.queryItems?.first(where: { $0.name == "sort" })?.value, let sort = SortEnum(rawValue: sortText) {
                        mangaSort = sort
                    }
                }
            }
            if let user = components.queryItems?.first(where: { $0.name == "user" })?.value, user.lowercased() != networker.user?.name?.lowercased() {
                tab = 2
                exploreRouter.restartWith(UserList(username: user, id: id, type: itemType, animeStatus: animeStatus, animeSort: animeSort, mangaStatus: mangaStatus, mangaSort: mangaSort))
                isSearchPresented = false
            } else {
                tab = 3
                myListRouter.popToRoot()
                self.listType = itemType
                self.animeStatus = animeStatus
                self.animeSort = animeSort
                self.mangaStatus = mangaStatus
                self.mangaSort = mangaSort
            }
        } else if page == "settings" {
            tab = 4
            settingsRouter.popToRoot()
        } else if page == "news" {
            tab = 2
            exploreRouter.restartWith("news")
            isSearchPresented = false
        } else if let idText = components.queryItems?.first(where: { $0.name == "id" })?.value, let id = Int(idText) {
            if let typeText = components.queryItems?.first(where: { $0.name == "type" })?.value, (typeText == "anime" || typeText == "manga") && page == "genre" {
                guard let type = TypeEnum(rawValue: typeText), let name = genreName(id: id, type: type) else {
                    return
                }

                tab = 2
                exploreRouter.restartWith(GroupDetail(id: id, name: name, type: type, group: "genres"))
                isSearchPresented = false
            } else if page == "anime" || page == "manga" || page == "character" || page == "person" {
                guard let viewType = ViewTypeEnum(rawValue: page) else {
                    return
                }

                tab = 2
                exploreRouter.restartWith(ViewItem(type: viewType, id: id))
                isSearchPresented = false
            } else if page == "producer" || page == "magazine" {
                tab = 2
                let name = components.queryItems?.first(where: { $0.name == "name" })?.value ?? ""
                exploreRouter.restartWith(GroupDetail(id: id, name: name, type: page == "producer" ? .anime : .manga, group: "\(page)s"))
                isSearchPresented = false
            }
        } else if let user = components.queryItems?.first(where: { $0.name == "user" })?.value, page == "profile" {
            if user.lowercased() == networker.user?.name?.lowercased() {
                tab = 4
                settingsRouter.restartWith("profile")
            } else {
                tab = 2
                exploreRouter.restartWith(UserList(username: user))
                isSearchPresented = false
            }
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
            }
        }
        .onAppear {
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
                    settingsRouter.restartWith("profile")
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
        VStack {
            if isUnlocked || !settings.useFaceID {
                if #available (iOS 26.2, *), horizontalSizeClass == .compact {
                    tabs
                        .tabBarMinimizeBehavior(.onScrollDown)
                        .tabViewBottomAccessory(isEnabled: showSeasonsTabViewBottomAccessory || showExploreTabViewBottomAccessory || showMyListTabViewBottomAccessory || showUserListTabViewBottomAccessory) {
                            tabViewBottomAccessory
                        }
                } else {
                    tabs
                }
            } else {
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

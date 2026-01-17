//
//  ContentView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import LocalAuthentication

struct MainView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var networker = NetworkManager.shared
    @State private var tab: Int = 0
    @State private var isUnlocked = false
    @State private var isAuthenticationError = false
    @State private var url: URL?
    
    // Top tab
    @State private var topId = UUID() // To reset NavigationStack to root
    @State private var topType: TypeEnum?
    @State private var animeRanking: RankingEnum?
    @State private var mangaRanking: RankingEnum?
    
    // Seasons tab
    @State private var seasonsId = UUID() // To reset NavigationStack to root
    @State private var year: Int?
    @State private var season: SeasonEnum?
    
    // Explore tab
    @State private var exploreId = UUID() // To reset NavigationStack to root
    @State private var explorePath = [ViewItem]()
    @State private var isSearchPresented = false
    @State private var isSearchRoot = true
    @State private var urlSearchText: String?
    
    // My list tab
    @State private var listId = UUID() // To reset NavigationStack to root
    @State private var listType: TypeEnum?
    @State private var animeStatus: StatusEnum?
    @State private var animeSort: SortEnum?
    @State private var mangaStatus: StatusEnum?
    @State private var mangaSort: SortEnum?
    
    // Settings tab
    @State private var settingsId = UUID() // To reset NavigationStack to root
    
    private var tabBinding: Binding<Int> { Binding(
        get: {
            self.tab
        },
        set: {
            if $0 == self.tab && self.tab == 2 && isSearchRoot {
                isSearchPresented = true
            }
            self.tab = $0
        }
    )}
    
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
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

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
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
    
    // Handle deep links
    private func handleUrl(url: URL) {
        print(url)
        let FIREBASE_LINK = Bundle.main.infoDictionary?["FIREBASE_LINK"] as! String
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }
        
        var page: String
        // Check for correct urls
        if url.scheme == "hako", let host = components.host {
            page = host
        } else if url.host == FIREBASE_LINK {
            page = String(components.path.dropFirst())
        } else {
            return
        }
        
        self.url = nil
        if page == "top" {
            tab = 0
            topId = UUID()
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
        } else if page == "seasons" {
            tab = 1
            seasonsId = UUID()
            if let yearText = components.queryItems?.first(where: { $0.name == "year" })?.value, let yearInt = Int(yearText), let seasonText = components.queryItems?.first(where: { $0.name == "season" })?.value, let seasonEnum = SeasonEnum(rawValue: seasonText), yearInt >= 1917 && yearInt <= Constants.currentYear + 1 {
                year = yearInt
                season = seasonEnum
            }
        } else if page == "explore" {
            tab = 2
            exploreId = UUID()
            if let text = components.queryItems?.first(where: { $0.name == "query" })?.value {
                explorePath = []
                isSearchPresented = true
                urlSearchText = text
            } else if let type = components.queryItems?.first(where: { $0.name == "type" })?.value {
                isSearchPresented = false
                if type == "anime" {
                    explorePath.append(ViewItem(type: .exploreAnime, id: 1))
                } else if type == "manga" {
                    explorePath.append(ViewItem(type: .exploreManga, id: 1))
                } else if type == "characters" {
                    explorePath.append(ViewItem(type: .exploreCharacters, id: 1))
                } else if type == "people" {
                    explorePath.append(ViewItem(type: .explorePeople, id: 1))
                } else if type == "studios" {
                    explorePath.append(ViewItem(type: .exploreStudios, id: 1))
                } else if type == "magazines" {
                    explorePath.append(ViewItem(type: .exploreMagazines, id: 1))
                }
            }
        } else if page == "mylist" {
            var listType: TypeEnum?
            var animeStatus: StatusEnum?
            var animeSort: SortEnum?
            var mangaStatus: StatusEnum?
            var mangaSort: SortEnum?
            if let type = components.queryItems?.first(where: { $0.name == "type" })?.value {
                if type == "anime" {
                    listType = .anime
                    if let statusText = components.queryItems?.first(where: { $0.name == "status" })?.value, let status = StatusEnum(rawValue: statusText), status != .reading && status != .planToRead {
                        animeStatus = status
                    }
                    if let sortText = components.queryItems?.first(where: { $0.name == "sort" })?.value, let sort = SortEnum(rawValue: sortText) {
                        animeSort = sort
                    }
                } else if type == "manga" {
                    listType = .manga
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
                exploreId = UUID()
                isSearchPresented = false
                explorePath.append(ViewItem(type: .userlist, id: 1, name: user, listType: listType, animeStatus: animeStatus, animeSort: animeSort, mangaStatus: mangaStatus, mangaSort: mangaSort))
            } else {
                tab = 3
                listId = UUID()
                self.listType = listType
                self.animeStatus = animeStatus
                self.animeSort = animeSort
                self.mangaStatus = mangaStatus
                self.mangaSort = mangaSort
            }
        } else if page == "settings" {
            tab = 4
            settingsId = UUID()
        } else if page == "news" {
            tab = 2
            exploreId = UUID()
            isSearchPresented = false
            explorePath.append(ViewItem(type: .news, id: 1))
        } else if let idText = components.queryItems?.first(where: { $0.name == "id" })?.value, let id = Int(idText) {
            if let type = components.queryItems?.first(where: { $0.name == "type" })?.value, (type == "anime" || type == "manga") && page == "genre" {
                tab = 2
                exploreId = UUID()
                isSearchPresented = false
                explorePath.append(ViewItem(type: type == "anime" ? .animeGenre : .mangaGenre, id: id))
            } else if page == "anime" || page == "manga" || page == "character" || page == "person" {
                tab = 2
                exploreId = UUID()
                isSearchPresented = false
                explorePath.append(ViewItem(type: ViewTypeEnum(rawValue: page)!, id: id))
            } else if page == "producer" || page == "magazine" {
                tab = 2
                exploreId = UUID()
                isSearchPresented = false
                let name = components.queryItems?.first(where: { $0.name == "name" })?.value
                explorePath.append(ViewItem(type: ViewTypeEnum(rawValue: page)!, id: id, name: name))
            }
        }
    }
    
    var body: some View {
        VStack {
            if isUnlocked || !settings.useFaceID {
                if #available(iOS 18.0, *) {
                    TabView(selection: tabBinding) {
                        if !settings.hideTop {
                            Tab("Top", systemImage: "medal", value: 0) {
                                TopView(id: $topId, type: $topType, animeRanking: $animeRanking, mangaRanking: $mangaRanking)
                            }
                        }
                        Tab("Seasons", systemImage: "calendar", value: 1) {
                            SeasonsView(id: $seasonsId, year: $year, season: $season)
                        }
                        Tab("Explore", systemImage: "magnifyingglass", value: 2, role: .search) {
                            ExploreView(id: $exploreId, path: $explorePath, isPresented: $isSearchPresented, isRoot: $isSearchRoot, urlSearchText: $urlSearchText)
                        }
                        if !settings.useWithoutAccount {
                            Tab("My list", systemImage: "list.bullet", value: 3) {
                                MyListView(id: $listId, type: $listType, animeStatus: $animeStatus, animeSort: $animeSort, mangaStatus: $mangaStatus, mangaSort: $mangaSort)
                            }
                        }
                        Tab("Settings", systemImage: "gear", value: 4) {
                            SettingsView(id: $settingsId)
                        }
                    }
                    .onAppear {
                        tab = settings.defaultView
                    }
                } else {
                    TabView(selection: tabBinding) {
                        if !settings.hideTop {
                            TopView(id: $topId, type: $topType, animeRanking: $animeRanking, mangaRanking: $mangaRanking)
                                .tabItem {
                                    Label("Top", systemImage: "medal")
                                }
                                .tag(0)
                        }
                        SeasonsView(id: $seasonsId, year: $year, season: $season)
                            .tabItem {
                                Label("Seasons", systemImage: "calendar")
                            }
                            .tag(1)
                        ExploreView(id: $exploreId, path: $explorePath, isPresented: $isSearchPresented, isRoot: $isSearchRoot, urlSearchText: $urlSearchText)
                            .tabItem {
                                Label("Explore", systemImage: "magnifyingglass")
                            }
                            .tag(2)
                        if !settings.useWithoutAccount {
                            MyListView(id: $listId, type: $listType, animeStatus: $animeStatus, animeSort: $animeSort, mangaStatus: $mangaStatus, mangaSort: $mangaSort)
                                .tabItem {
                                    Label("My list", systemImage: "list.bullet")
                                }
                                .tag(3)
                        }
                        SettingsView(id: $settingsId)
                            .tabItem {
                                Label("Settings", systemImage: "gear")
                            }
                            .tag(4)
                    }
                    .onAppear {
                        tab = settings.defaultView
                    }
                }
            } else {
                VStack {
                    Text("Hako is locked")
                        .font(.title)
                        .bold()
                    Button("Unlock") {
                        authenticate()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
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

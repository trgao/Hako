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
    @State private var tab: Int = 0
    @State private var isUnlocked = false
    @State private var isAuthenticationError = false
    @State private var isSearchPresented = false
    @State private var isSearchRoot = true
    @State private var explorePath = [ViewItem]()
    @State private var urlSearchText = ""
    @State private var urlItemType = ViewTypeEnum.none
    @State private var urlItemId: Int?
    
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    var tabBinding: Binding<Int> { Binding(
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
    
    func authenticate() {
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
    
    var body: some View {
        VStack {
            if isUnlocked || !settings.useFaceID {
                if #available(iOS 18.0, *) {
                    TabView(selection: tabBinding) {
                        if !settings.hideTop {
                            Tab("Top", systemImage: "medal", value: 0) {
                                TopView()
                            }
                        }
                        Tab("Seasons", systemImage: "calendar", value: 1) {
                            SeasonsView()
                        }
                        Tab("Explore", systemImage: "magnifyingglass", value: 2, role: .search) {
                            ExploreView(isPresented: $isSearchPresented, isRoot: $isSearchRoot, path: $explorePath, urlSearchText: $urlSearchText)
                        }
                        if !settings.useWithoutAccount {
                            Tab("My list", systemImage: "list.bullet", value: 3) {
                                MyListView()
                            }
                        }
                        Tab("Settings", systemImage: "gear", value: 4) {
                            SettingsView()
                        }
                    }
                    .onAppear {
                        tab = settings.defaultView
                    }
                } else {
                    TabView(selection: tabBinding) {
                        if !settings.hideTop {
                            TopView()
                                .tabItem {
                                    Label("Top", systemImage: "medal")
                                }
                                .tag(0)
                        }
                        SeasonsView()
                            .tabItem {
                                Label("Seasons", systemImage: "calendar")
                            }
                            .tag(1)
                        ExploreView(isPresented: $isSearchPresented, isRoot: $isSearchRoot, path: $explorePath, urlSearchText: $urlSearchText)
                            .tabItem {
                                Label("Explore", systemImage: "magnifyingglass")
                            }
                            .tag(2)
                        if !settings.useWithoutAccount {
                            MyListView()
                                .tabItem {
                                    Label("My list", systemImage: "list.bullet")
                                }
                                .tag(3)
                        }
                        SettingsView()
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
        .onOpenURL { url in
            // Check for correct url scheme
            guard url.scheme == "hako" else {
                return
            }
            
            // Check for url components and host
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true), let host = components.host else {
                return
            }
            
            if host == "top" {
                tab = 0
            } else if host == "seasons" {
                tab = 1
            } else if host == "explore" {
                tab = 2
                if let text = components.queryItems?.first(where: { $0.name == "query" })?.value {
                    isSearchPresented = true
                    urlSearchText = text
                }
            } else if host == "mylist" {
                tab = 3
            } else if host == "settings" {
                tab = 4
            } else if host == "news" {
                tab = 2
                isSearchPresented = false
                explorePath.append(ViewItem(type: .news, id: 1))
            } else if let idText = components.queryItems?.first(where: { $0.name == "id" })?.value, let id = Int(idText) {
                if let type = components.queryItems?.first(where: { $0.name == "type" })?.value, (type == "anime" || type == "manga") && host == "genre" {
                    tab = 2
                    isSearchPresented = false
                    explorePath.append(ViewItem(type: type == "anime" ? .animeGenre : .mangaGenre, id: id))
                } else if host == "anime" || host == "manga" || host == "character" || host == "person" || host == "producer" || host == "magazine" {
                    tab = 2
                    isSearchPresented = false
                    explorePath.append(ViewItem(type: ViewTypeEnum(value: host), id: id))
                }
            }
        }
    }
}

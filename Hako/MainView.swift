//
//  ContentView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var settings: SettingsManager
    @State private var tab: Int = 0
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
    
    var body: some View {
        TabView(selection: $tab) {
            TopView()
                .tabItem {
                    Label("Top", systemImage: "medal")
                }
                .tag(0)
            SeasonsView()
                .tabItem {
                    Label("Seasons", systemImage: "calendar")
                }
                .tag(1)
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(2)
            if !settings.useWithoutAccount {
                MyListView()
                    .tabItem {
                        Label("My List", systemImage: "list.bullet")
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
}

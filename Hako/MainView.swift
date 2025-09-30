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
                        Tab("Search", systemImage: "magnifyingglass", value: 2, role: .search) {
                            SearchView(isPresented: $isSearchPresented, isRoot: $isSearchRoot)
                        }
                        if !settings.useWithoutAccount {
                            Tab("My List", systemImage: "list.bullet", value: 3) {
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
                        SearchView(isPresented: $isSearchPresented, isRoot: $isSearchRoot)
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
            } else {
                Button("Unlock") {
                    authenticate()
                }
                .buttonStyle(.borderedProminent)
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
    }
}

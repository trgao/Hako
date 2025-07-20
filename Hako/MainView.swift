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
    private let context = LAContext()
    
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    func authenticate() {
        guard settings.useFaceID else {
            return
        }
        
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
                TabView(selection: $tab) {
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
            }
        }
    }
}

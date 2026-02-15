//
//  GeneralView.swift
//  Hako
//
//  Created by Gao Tianrun on 20/11/24.
//

import SwiftUI
import LocalAuthentication

struct GeneralView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var networker = NetworkManager.shared
    @State private var isAuthenticationError = false
    @State private var cacheSizeString = ""
    private let cacheManager = CacheManager.shared
    
    var body: some View {
        List {
            Section("General") {
                PickerRow(title: "Preferred title language", selection: $settings.preferredTitleLanguage, labels: ["Romaji", "English"])
                PickerRow(title: "Default view", selection: $settings.defaultView, labels: [settings.hideTop ? "" : "Top", "Seasons", "Explore", settings.useWithoutAccount ? "" : "My list"])
                Toggle(isOn: $settings.hideTop) {
                    Text("Hide top tab")
                }
                .onChange(of: settings.hideTop) { _, cur in
                    if cur == true && settings.defaultView == 0 {
                        settings.defaultView = 1
                    }
                }
                Toggle(isOn: $settings.useWithoutAccount) {
                    Text("Use app without account")
                    Text("It will hide the login button and My list tab")
                }
                .onChange(of: settings.useWithoutAccount) { _, cur in
                    if cur == true && settings.defaultView == 3 {
                        settings.defaultView = settings.hideTop ? 1 : 0
                    }
                }
                Toggle(isOn: $settings.safariInApp) {
                    Text("Open links in app")
                }
            }
            let context = LAContext()
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                Section("Privacy") {
                    Toggle(isOn: Binding(
                        get: { settings.useFaceID },
                        set: { value in
                            let reason = "Face ID is required to change settings"
                            
                            if !value {
                                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                                    if success {
                                        DispatchQueue.main.async {
                                            settings.useFaceID = false
                                        }
                                    } else {
                                        isAuthenticationError = true
                                    }
                                }
                            } else {
                                settings.useFaceID = true
                            }
                        }
                    )) {
                        Text("Use Face ID to lock app")
                    }
                }
            }
            Section("Top") {
                let animeRankings = Constants.animeRankings.map{ $0.toString() }
                let mangaRankings = Constants.mangaRankings.map{ $0.toString() }
                PickerRow(title: "Default anime ranking", selection: $settings.defaultAnimeRanking, labels: animeRankings)
                PickerRow(title: "Default manga ranking", selection: $settings.defaultMangaRanking, labels: mangaRankings)
            }
            Section("User list") {
                Toggle(isOn: $settings.useStatusTabBar) {
                    Text("Use list status tab bar")
                    Text(settings.useStatusTabBar ?  "You can change user list status from the tab bar at the bottom of the page" : "You can change user list status from the menu icon in the navigation bar")
                }
                
                let animeStatuses = Constants.animeStatuses.map{ $0.toString() }
                let animeSorts = Constants.animeSorts.map{ $0.toString() }
                PickerRow(title: "Default anime status", selection: $settings.defaultAnimeStatus, labels: animeStatuses)
                PickerRow(title: "Default anime sort", selection: $settings.defaultAnimeSort, labels: animeSorts)
                
                let mangaStatuses = Constants.mangaStatuses.map{ $0.toString() }
                let mangaSorts = Constants.mangaSorts.map{ $0.toString() }
                PickerRow(title: "Default manga status", selection: $settings.defaultMangaStatus, labels: mangaStatuses)
                PickerRow(title: "Default manga sort", selection: $settings.defaultMangaSort, labels: mangaSorts)
                
                if networker.isSignedIn {
                    Toggle(isOn: $settings.useSwipeActions) {
                        Text("Allow swipe actions")
                        Text("Swipe left or right on items in My list tab to increase or decrease episodes watched and \(settings.mangaReadProgress == 0 ? "chapters" : "volumes") read")
                    }
                    PickerRow(title: "Manga read progress", selection: $settings.mangaReadProgress, labels: ["Chapters", "Volumes"])
                }
            }
            if networker.isSignedIn {
                Section("Edit") {
                    Toggle(isOn: $settings.autofillStartDate) {
                        Text("Autofill start date")
                        Text("Autofill start date when an anime is changed to watching or a manga is changed to reading")
                    }
                    Toggle(isOn: $settings.autofillEndDate) {
                        Text("Autofill end date")
                        Text("Autofill end date when an anime or a manga is changed to completed")
                    }
                }
            }
            if !ProcessInfo.processInfo.isMacCatalystApp {
                Section {
                    Button("Clear cache", role: .destructive) {
                        Task {
                            await cacheManager.clearCache()
                            cacheSizeString = await cacheManager.calculateCacheSize()
                        }
                    }
                } footer: {
                    Text("Cache size: \(cacheSizeString)")
                        .padding(.bottom, 10)
                }
            }
        }
        .task {
            cacheSizeString = await cacheManager.calculateCacheSize()
        }
        .alert("Unable to change settings", isPresented: $isAuthenticationError) {
            Button("Ok") {}
        }
    }
}

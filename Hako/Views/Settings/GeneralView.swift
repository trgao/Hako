//
//  GeneralView.swift
//  Hako
//
//  Created by Gao Tianrun on 20/11/24.
//

import SwiftUI

struct GeneralView: View {
    @EnvironmentObject private var settings: SettingsManager
    let networker = NetworkManager.shared
    
    var body: some View {
        List {
            Section("General") {
                Toggle(isOn: $settings.safariInApp) {
                    Text("Open links in app")
                }
                Toggle(isOn: $settings.useWithoutAccount) {
                    Text("Use app without account")
                    Text("It will hide the login view and my list tab")
                }
                .onChange(of: settings.useWithoutAccount) { _, cur in
                    if cur == true && settings.defaultView == 3 {
                        settings.defaultView = settings.hideTop ? 1 : 0
                    }
                }
                Toggle(isOn: $settings.hideTop) {
                    Text("Hide top tab")
                }
                .onChange(of: settings.hideTop) { _, cur in
                    if cur == true && settings.defaultView == 0 {
                        settings.defaultView = 1
                    }
                }
                if networker.isSignedIn {
                    Toggle(isOn: $settings.hideRecommendations) {
                        Text("Hide recommendations")
                    }
                }
                PickerRow(title: "Preferred title language", selection: $settings.preferredTitleLanguage, labels: ["Romaji", "English"])
                PickerRow(title: "Default view", selection: $settings.defaultView, labels: [settings.hideTop ? "" : "Top", "Seasons", "Search", settings.useWithoutAccount ? "" : "My List"])
            }
            Section("Grid view") {
                Toggle(isOn: $settings.truncate) {
                    Text("Truncate titles or names")
                }
                PickerRow(title: "Line limit", selection: $settings.lineLimit, labels: ["1", "2", "3"])
                    .disabled(!settings.truncate)
            }
            if networker.isSignedIn {
                Section("List view") {
                    Toggle(isOn: $settings.useSwipeActions) {
                        Text("Enable swipe actions")
                        Text("Swipe left or right on items in My List tab to increase or decrease episodes watched and \(settings.mangaSwipeActions == 0 ? "chapters" : "volumes") read")
                    }
                    PickerRow(title: "Manga swipe actions", selection: $settings.mangaSwipeActions, labels: ["Chapters", "Volumes"])
                        .disabled(!settings.useSwipeActions)
                    PickerRow(title: "Manga read progress", selection: $settings.mangaReadProgress, labels: ["Chapters", "Volumes"])
                }
            }
            Section("Anime details") {
                Toggle(isOn: $settings.hideTrailers) {
                    Text("Hide trailers")
                }
                if networker.isSignedIn {
                    Toggle(isOn: $settings.hideAnimeProgress) {
                        Text("Hide watch progress")
                    }
                }
                Toggle(isOn: $settings.hideAnimeCharacters) {
                    Text("Hide characters")
                }
                Toggle(isOn: $settings.hideStaffs) {
                    Text("Hide staffs")
                }
                Toggle(isOn: $settings.hideAnimeRelated) {
                    Text("Hide related")
                }
                Toggle(isOn: $settings.hideThemeSongs) {
                    Text("Hide theme songs")
                }
                Toggle(isOn: $settings.hideAnimeStatistics) {
                    Text("Hide statistics")
                }
            }
            Section("Manga details") {
                if networker.isSignedIn {
                    Toggle(isOn: $settings.hideMangaProgress) {
                        Text("Hide read progress")
                    }
                }
                Toggle(isOn: $settings.hideMangaCharacters) {
                    Text("Hide characters")
                }
                Toggle(isOn: $settings.hideAuthors) {
                    Text("Hide authors")
                }
                Toggle(isOn: $settings.hideMangaRelated) {
                    Text("Hide related")
                }
                Toggle(isOn: $settings.hideMangaStatistics) {
                    Text("Hide statistics")
                }
            }
        }
    }
}

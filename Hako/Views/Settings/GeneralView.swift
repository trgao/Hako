//
//  GeneralView.swift
//  Hako
//
//  Created by Gao Tianrun on 20/11/24.
//

import SwiftUI

struct GeneralView: View {
    @EnvironmentObject private var settings: SettingsManager
    
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
                Toggle(isOn: $settings.hideRecommendations) {
                    Text("Hide recommendations")
                }
                PickerRow(title: "Default view", selection: $settings.defaultView, labels: [settings.hideTop ? "" : "Top", "Seasons", "Search", settings.useWithoutAccount ? "" : "My List"])
            }
            Section("Grid view") {
                Toggle(isOn: $settings.truncate) {
                    Text("Truncate titles or names")
                }
                PickerRow(title: "Line limit", selection: $settings.lineLimit, labels: ["1", "2", "3"])
                    .disabled(!settings.truncate)
            }
            Section("Anime details") {
                Toggle(isOn: $settings.hideTrailers) {
                    Text("Hide trailers")
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
                Toggle(isOn: $settings.useChapterProgress) {
                    Text("Use chapters for progress")
                    Text(settings.useChapterProgress ? "This will use number of chapters read for manga read progress" : "This will use number of volumes read for manga read progress")
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

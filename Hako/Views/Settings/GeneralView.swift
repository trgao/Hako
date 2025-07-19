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
    
    var animeDetails: some View {
        List {
            if networker.isSignedIn {
                Toggle(isOn: $settings.hideAnimeProgress) {
                    Text("Hide watch progress")
                }
            }
            Toggle(isOn: $settings.hideAnimeInformation) {
                Text("Hide anime information")
            }
            Toggle(isOn: $settings.hideAiringSchedule) {
                Text("Hide airing schedule")
            }
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
            if networker.isSignedIn {
                Toggle(isOn: $settings.hideAnimeRecommendations) {
                    Text("Hide recommendations")
                }
            }
            Toggle(isOn: $settings.hideThemeSongs) {
                Text("Hide theme songs")
            }
            Toggle(isOn: $settings.hideAnimeReviews) {
                Text("Hide reviews")
            }
            Toggle(isOn: $settings.hideAnimeStatistics) {
                Text("Hide statistics")
            }
        }
        .navigationTitle("Anime details")
    }
    
    var mangaDetails: some View {
        List {
            if networker.isSignedIn {
                Toggle(isOn: $settings.hideMangaProgress) {
                    Text("Hide read progress")
                }
            }
            Toggle(isOn: $settings.hideMangaInformation) {
                Text("Hide manga information")
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
            if networker.isSignedIn {
                Toggle(isOn: $settings.hideMangaRecommendations) {
                    Text("Hide recommendations")
                }
            }
            Toggle(isOn: $settings.hideMangaReviews) {
                Text("Hide reviews")
            }
            Toggle(isOn: $settings.hideMangaStatistics) {
                Text("Hide statistics")
            }
        }
        .navigationTitle("Manga details")
    }
    
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
                PickerRow(title: "Preferred title language", selection: $settings.preferredTitleLanguage, labels: ["Romaji", "English"])
                PickerRow(title: "Default view", selection: $settings.defaultView, labels: [settings.hideTop ? "" : "Top", "Seasons", "Search", settings.useWithoutAccount ? "" : "My List"])
                Toggle(isOn: $settings.useFaceID) {
                    Text("Use Face ID to lock anime and manga list")
                }
            }
            Section("Grid view") {
                Toggle(isOn: $settings.truncate) {
                    Text("Truncate titles or names")
                }
                PickerRow(title: "Line limit", selection: $settings.lineLimit, labels: ["1", "2", "3"])
                    .disabled(!settings.truncate)
            }
            Section("Seasons view") {
                Toggle(isOn: $settings.hideContinuingSeries) {
                    Text("Hide continuing series")
                }
            }
            Section("Search view") {
                Toggle(isOn: $settings.hideRandom) {
                    Text("Hide random button")
                }
                if networker.isSignedIn {
                    Toggle(isOn: $settings.hideForYou) {
                        Text("Hide for you")
                    }
                }
                Toggle(isOn: $settings.hideTopAiring) {
                    Text("Hide top airing")
                }
                Toggle(isOn: $settings.hideTopUpcoming) {
                    Text("Hide top upcoming")
                }
                Toggle(isOn: $settings.hideMostPopularAnime) {
                    Text("Hide most popular anime")
                }
                Toggle(isOn: $settings.hideMostPopularManga) {
                    Text("Hide most popular manga")
                }
            }
            if networker.isSignedIn {
                Section("List view") {
                    Toggle(isOn: $settings.useSwipeActions) {
                        Text("Enable swipe actions")
                        Text("Swipe left or right on items in My List tab to increase or decrease episodes watched and \(settings.mangaReadProgress == 0 ? "chapters" : "volumes") read")
                    }
                    PickerRow(title: "Manga read progress", selection: $settings.mangaReadProgress, labels: ["Chapters", "Volumes"])
                }
            }
            Section("Details view") {
                NavigationLink("Anime details") {
                    animeDetails
                }
                NavigationLink("Manga details") {
                    mangaDetails
                }
            }
        }
    }
}

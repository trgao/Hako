//
//  HideItemsView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/07/25.
//

import SwiftUI
import LocalAuthentication

struct HideItemsView: View {
    @EnvironmentObject private var settings: SettingsManager
    let networker = NetworkManager.shared
    
    var body: some View {
        List {
            Section("Seasons") {
                Toggle(isOn: $settings.hideContinuingSeries) {
                    Text("Hide continuing series")
                }
            }
            Section("Search") {
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
            Section("Anime details") {
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
            Section("Manga details") {
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
        }
    }
}

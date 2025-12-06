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
            Section("Explore") {
                Toggle(isOn: $settings.hideRandom) {
                    Text("Hide random button")
                }
                Toggle(isOn: $settings.hideExploreAnimeManga) {
                    Text("Hide explore anime and manga")
                }
                Toggle(isOn: $settings.hideNews) {
                    Text("Hide news")
                }
                Toggle(isOn: $settings.hideRecentlyViewed) {
                    Text("Hide recently viewed")
                }
                if networker.isSignedIn {
                    Toggle(isOn: $settings.hideAnimeForYou) {
                        Text("Hide anime for you")
                    }
                }
                Toggle(isOn: $settings.hideTopAiringAnime) {
                    Text("Hide top airing anime")
                }
                Toggle(isOn: $settings.hideTopUpcomingAnime) {
                    Text("Hide top upcoming anime")
                }
                Toggle(isOn: $settings.hideNewlyAddedAnime) {
                    Text("Hide newly added anime")
                }
                Toggle(isOn: $settings.hideNewlyAddedManga) {
                    Text("Hide newly added manga")
                }
            }
            Section("User profile") {
                Toggle(isOn: $settings.hideUserAnimeStatistics) {
                    Text("Hide anime statistics")
                }
                Toggle(isOn: $settings.hideUserMangaStatistics) {
                    Text("Hide manga statistics")
                }
                Toggle(isOn: $settings.hideUserFavouriteAnime) {
                    Text("Hide favourite anime")
                }
                Toggle(isOn: $settings.hideUserFavouriteManga) {
                    Text("Hide favourite manga")
                }
                Toggle(isOn: $settings.hideUserFavouriteCharacters) {
                    Text("Hide favourite characters")
                }
                Toggle(isOn: $settings.hideUserFavouritePeople) {
                    Text("Hide favourite people")
                }
            }
            Section("Anime details") {
                if networker.isSignedIn {
                    Toggle(isOn: $settings.hideAnimeProgress) {
                        Text("Hide watch progress")
                    }
                }
                Toggle(isOn: $settings.hideAnimeInformation) {
                    Text("Hide information")
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
                Toggle(isOn: $settings.hideThemeSongsSearch) {
                    Text("Hide search in Spotify and Apple Music")
                }
                Toggle(isOn: $settings.hideAnimeReviews) {
                    Text("Hide reviews")
                }
            }
            Section("Manga details") {
                if networker.isSignedIn {
                    Toggle(isOn: $settings.hideMangaProgress) {
                        Text("Hide read progress")
                    }
                }
                Toggle(isOn: $settings.hideMangaInformation) {
                    Text("Hide information")
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
            }
        }
    }
}

//
//  SettingsManager.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI
import Foundation

@MainActor
class SettingsManager: ObservableObject {
    @AppStorage("safariInApp") var safariInApp = true
    @AppStorage("useWithoutAccount") var useWithoutAccount = false
    @AppStorage("hideTop") var hideTop = false
    @AppStorage("preferredTitleLanguage") var preferredTitleLanguage = 0
    @AppStorage("defaultView") var defaultView = 0
    
    @AppStorage("truncateTitle") var truncate = false
    @AppStorage("lineLimit") var lineLimit = 1
    
    @AppStorage("hideContinuingSeries") var hideContinuingSeries = false
    
    @AppStorage("hideForYou") var hideForYou = false
    @AppStorage("hideTopAiring") var hideTopAiring = false
    @AppStorage("hideTopUpcoming") var hideTopUpcoming = false
    @AppStorage("hideMostPopularAnime") var hideMostPopularAnime = false
    @AppStorage("hideMostPopularManga") var hideMostPopularManga = false
    
    @AppStorage("useSwipeActions") var useSwipeActions = true
    @AppStorage("mangaSwipeActions") var mangaSwipeActions = 0
    @AppStorage("mangaReadProgress") var mangaReadProgress = 0
    
    @AppStorage("hideAnimeProgress") var hideAnimeProgress = false
    @AppStorage("hideAiring") var hideAiring = false
    @AppStorage("hideTrailers") var hideTrailers = false
    @AppStorage("hideAnimeCharacters") var hideAnimeCharacters = false
    @AppStorage("hideStaffs") var hideStaffs = false
    @AppStorage("hideAnimeRelated") var hideAnimeRelated = false
    @AppStorage("hideAnimeRecommendations") var hideAnimeRecommendations = false
    @AppStorage("hideThemeSongs") var hideThemeSongs = false
    @AppStorage("hideAnimeReviews") var hideAnimeReviews = false
    @AppStorage("hideAnimeStatistics") var hideAnimeStatistics = false
    
    @AppStorage("hideMangaProgress") var hideMangaProgress = false
    @AppStorage("hideMangaCharacters") var hideMangaCharacters = false
    @AppStorage("hideAuthors") var hideAuthors = false
    @AppStorage("hideMangaRelated") var hideMangaRelated = false
    @AppStorage("hideMangaRecommendations") var hideMangaRecommendations = false
    @AppStorage("hideMangaReviews") var hideMangaReviews = false
    @AppStorage("hideMangaStatistics") var hideMangaStatistics = false
    
    @AppStorage("colorScheme") var colorScheme = 0
    @AppStorage("accentColor") var accentColor = 0
    @AppStorage("translucentBackground") var translucentBackground = true
    
    var colorSchemes: [ColorScheme?] = [nil, .light, .dark]
    var accentColors: [Color] = [.blue, .teal, .orange, .pink, .indigo, .purple, .green, .brown]
    
    func getLineLimit() -> Int? {
        return truncate ? lineLimit + 1 : nil
    }
    
    func getColorScheme() -> ColorScheme? {
        return colorSchemes[colorScheme]
    }
    
    func getAccentColor() -> Color {
        return accentColors[accentColor]
    }
}

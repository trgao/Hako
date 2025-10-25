//
//  SettingsManager.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

@MainActor
class SettingsManager: ObservableObject {
    @AppStorage("preferredTitleLanguage") var preferredTitleLanguage = 0
    @AppStorage("defaultView") var defaultView = 0
    @AppStorage("hideTop") var hideTop = false
    @AppStorage("useWithoutAccount") var useWithoutAccount = false
    @AppStorage("safariInApp") var safariInApp = true
    
    @AppStorage("useFaceID") var useFaceID = false
    
    @AppStorage("useSwipeActions") var useSwipeActions = true
    @AppStorage("mangaReadProgress") var mangaReadProgress = 0
    
    @AppStorage("autofillStartDate") var autofillStartDate = true
    @AppStorage("autofillEndDate") var autofillEndDate = true
    
    @AppStorage("colorScheme") var colorScheme = 0
    @AppStorage("accentColor") var accentColor = 0
    @AppStorage("translucentBackground") var translucentBackground = true
    
    @AppStorage("truncateTitle") var truncate = false
    @AppStorage("lineLimit") var lineLimit = 1
    
    @AppStorage("hideContinuingSeries") var hideContinuingSeries = false
    
    @AppStorage("hideRandom") var hideRandom = false
    @AppStorage("hideExploreAnimeManga") var hideExploreAnimeManga = false
    @AppStorage("hideAnimeForYou") var hideAnimeForYou = false
    @AppStorage("hideTopAiringAnime") var hideTopAiringAnime = false
    @AppStorage("hideTopUpcomingAnime") var hideTopUpcomingAnime = false
    @AppStorage("hideNewlyAddedAnime") var hideNewlyAddedAnime = false
    @AppStorage("hideNewlyAddedManga") var hideNewlyAddedManga = false
    
    @AppStorage("hideUserAnimeStatistics") var hideUserAnimeStatistics = false
    @AppStorage("hideUserMangaStatistics") var hideUserMangaStatistics = false
    @AppStorage("hideUserFavouriteAnime") var hideUserFavouriteAnime = false
    @AppStorage("hideUserFavouriteManga") var hideUserFavouriteManga = false
    @AppStorage("hideUserFavouriteCharacters") var hideUserFavouriteCharacters = false
    @AppStorage("hideUserFavouritePeople") var hideUserFavouritePeople = false
    
    @AppStorage("hideAnimeProgress") var hideAnimeProgress = false
    @AppStorage("hideAnimeInformation") var hideAnimeInformation = false
    @AppStorage("hideAiring") var hideAiringSchedule = false
    @AppStorage("hideTrailers") var hideTrailers = false
    @AppStorage("hideAnimeCharacters") var hideAnimeCharacters = false
    @AppStorage("hideStaffs") var hideStaffs = false
    @AppStorage("hideAnimeRelated") var hideAnimeRelated = false
    @AppStorage("hideAnimeRecommendations") var hideAnimeRecommendations = false
    @AppStorage("hideThemeSongs") var hideThemeSongs = false
    @AppStorage("hideAnimeReviews") var hideAnimeReviews = false
    
    @AppStorage("hideMangaProgress") var hideMangaProgress = false
    @AppStorage("hideMangaInformation") var hideMangaInformation = false
    @AppStorage("hideMangaCharacters") var hideMangaCharacters = false
    @AppStorage("hideAuthors") var hideAuthors = false
    @AppStorage("hideMangaRelated") var hideMangaRelated = false
    @AppStorage("hideMangaRecommendations") var hideMangaRecommendations = false
    @AppStorage("hideMangaReviews") var hideMangaReviews = false
    
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

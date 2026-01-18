//
//  SettingsManager.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

@MainActor
class SettingsManager: ObservableObject {
    // General
    @AppStorage("preferredTitleLanguage") var preferredTitleLanguage = 0
    @AppStorage("defaultView") var defaultView = 0
    @AppStorage("hideTop") var hideTop = false
    @AppStorage("useWithoutAccount") var useWithoutAccount = false
    @AppStorage("safariInApp") var safariInApp = true
    
    @AppStorage("useFaceID") var useFaceID = false
    
    @AppStorage("defaultAnimeRanking") var defaultAnimeRanking = 0
    @AppStorage("defaultMangaRanking") var defaultMangaRanking = 0
    
    @AppStorage("useStatusTabBar") var useStatusTabBar = true
    @AppStorage("defaultAnimeStatus") var defaultAnimeStatus = 1
    @AppStorage("defaultAnimeSort") var defaultAnimeSort = 2
    @AppStorage("defaultMangaStatus") var defaultMangaStatus = 1
    @AppStorage("defaultMangaSort") var defaultMangaSort = 2
    @AppStorage("useSwipeActions") var useSwipeActions = true
    @AppStorage("mangaReadProgress") var mangaReadProgress = 0
    
    @AppStorage("autofillStartDate") var autofillStartDate = true
    @AppStorage("autofillEndDate") var autofillEndDate = true
    
    // Appearance
    @AppStorage("colorScheme") var colorScheme = 0
    @AppStorage("accentColor") var accentColor = 0
    @AppStorage("translucentBackground") var translucentBackground = true
    
    @AppStorage("truncateTitle") var truncate = false
    @AppStorage("lineLimit") var lineLimit = 1
    
    // Hide items
    @AppStorage("hideContinuingSeries") var hideContinuingSeries = false
    
    @AppStorage("hideRandom") var hideRandom = false
    @AppStorage("hideExploreAnimeManga") var hideExploreAnimeManga = false
    @AppStorage("hideExploreCharactersPeople") var hideExploreCharactersPeople = false
    @AppStorage("hideNews") var hideNews = false
    @AppStorage("hideRecentlyViewed") var hideRecentlyViewed = false
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
    @AppStorage("hideThemeSongsSearch") var hideThemeSongsSearch = false
    @AppStorage("hideAnimeReviews") var hideAnimeReviews = false
    
    @AppStorage("hideMangaProgress") var hideMangaProgress = false
    @AppStorage("hideMangaInformation") var hideMangaInformation = false
    @AppStorage("hideMangaCharacters") var hideMangaCharacters = false
    @AppStorage("hideAuthors") var hideAuthors = false
    @AppStorage("hideMangaRelated") var hideMangaRelated = false
    @AppStorage("hideMangaRecommendations") var hideMangaRecommendations = false
    @AppStorage("hideMangaReviews") var hideMangaReviews = false
    
    @AppStorage("recentlyViewedItems") var recentlyViewedItems: [ListItem] = []
    
    func getAnimeRanking() -> RankingEnum {
        return Constants.animeRankings[defaultAnimeRanking]
    }
    
    func getMangaRanking() -> RankingEnum {
        return Constants.mangaRankings[defaultMangaRanking]
    }
    
    func getAnimeStatus() -> StatusEnum {
        return Constants.animeStatuses[defaultAnimeStatus]
    }
    
    func getAnimeSort() -> SortEnum {
        return Constants.animeSorts[defaultAnimeSort]
    }
    
    func getMangaStatus() -> StatusEnum {
        return Constants.mangaStatuses[defaultMangaStatus]
    }
    
    func getMangaSort() -> SortEnum {
        return Constants.mangaSorts[defaultMangaSort]
    }
    
    func getLineLimit() -> Int? {
        return truncate ? lineLimit + 1 : nil
    }
    
    func getColorScheme() -> ColorScheme? {
        return Constants.colorSchemes[colorScheme]
    }
    
    func getAccentColor() -> Color {
        return Constants.accentColors[accentColor]
    }
}

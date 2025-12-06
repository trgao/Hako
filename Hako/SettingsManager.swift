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
    
    @AppStorage("defaultAnimeRanking") var defaultAnimeRanking = 0
    @AppStorage("defaultMangaRanking") var defaultMangaRanking = 0
    
    @AppStorage("defaultAnimeStatus") var defaultAnimeStatus = 1
    @AppStorage("defaultAnimeSort") var defaultAnimeSort = 2
    @AppStorage("defaultMangaStatus") var defaultMangaStatus = 1
    @AppStorage("defaultMangaSort") var defaultMangaSort = 2
    
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
    
    var animeRankings = ["all", "tv", "ova", "movie", "special", "bypopularity", "favorite"]
    var mangaRankings = ["all", "manga", "novels", "oneshots", "manhwa", "manhua", "bypopularity", "favorite"]
    
    var animeStatuses: [StatusEnum] = [.none, .watching, .completed, .onHold, .dropped, .planToWatch]
    var animeSorts = ["list_score", "list_updated_at", "anime_title", "anime_start_date"]
    var mangaStatuses: [StatusEnum] = [.none, .reading, .completed, .onHold, .dropped, .planToRead]
    var mangaSorts = ["list_score", "list_updated_at", "manga_title", "manga_start_date"]
    
    var colorSchemes: [ColorScheme?] = [nil, .light, .dark]
    var accentColors: [Color] = [.blue, .teal, .orange, .pink, .indigo, .purple, .green, .brown]
    
    func getAnimeRanking() -> String {
        return animeRankings[defaultAnimeRanking]
    }
    
    func getMangaRanking() -> String {
        return mangaRankings[defaultMangaRanking]
    }
    
    func getAnimeStatus() -> StatusEnum {
        return animeStatuses[defaultAnimeStatus]
    }
    
    func getAnimeSort() -> String {
        return animeSorts[defaultAnimeSort]
    }
    
    func getMangaStatus() -> StatusEnum {
        return mangaStatuses[defaultMangaStatus]
    }
    
    func getMangaSort() -> String {
        return mangaSorts[defaultMangaSort]
    }
    
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

//
//  SeasonsViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import Foundation

@MainActor
class SeasonsViewController: ObservableObject {
    // Winter season variables
    @Published var winterItems: [MALListAnime] = []
    @Published var winterContinuingItems: [MALListAnime] = []
    @Published var isWinterUnreleased = false
    
    // Spring season variables
    @Published var springItems: [MALListAnime] = []
    @Published var springContinuingItems: [MALListAnime] = []
    @Published var isSpringUnreleased = false
    
    // Summer season variables
    @Published var summerItems: [MALListAnime] = []
    @Published var summerContinuingItems: [MALListAnime] = []
    @Published var isSummerUnreleased = false
    
    // Fall season variables
    @Published var fallItems: [MALListAnime] = []
    @Published var fallContinuingItems: [MALListAnime] = []
    @Published var isFallUnreleased = false
    
    // Common variables
    @Published var season = Constants.currentSeason
    @Published var year = Constants.currentYear
    @Published var loadingState: LoadingEnum = .loading
    private let networker = NetworkManager.shared
    
    // Check if the anime list for the current season is empty
    func isSeasonEmpty() -> Bool {
        return (season == .winter && winterItems.isEmpty) || (season == .spring && springItems.isEmpty) || (season == .summer && summerItems.isEmpty) || (season == .fall && fallItems.isEmpty)
    }
    
    // Check if the current season is unreleased
    func isSeasonUnreleased() -> Bool {
        return (season == .winter && isWinterUnreleased) || (season == .spring && isSpringUnreleased) || (season == .summer && isSummerUnreleased) || (season == .fall && isFallUnreleased)
    }
    
    // Check if the current anime list should be refreshed
    func shouldRefresh() -> Bool {
        return isSeasonEmpty() && !isSeasonUnreleased()
    }
    
    // Refresh the current season list
    func refresh(_ clear: Bool = false) async {
        // Reset all lists if need to clear (to change year)
        if clear {
            winterItems = []
            winterContinuingItems = []
            
            springItems = []
            springContinuingItems = []
            
            summerItems = []
            summerContinuingItems = []
            
            fallItems = []
            fallContinuingItems = []
        }
        
        loadingState = .loading
        do {
            var initialList = try await networker.getSeasonAnimeList(season: season, year: year, page: 1)
            
            // Anime seasons have never exceeded 500 items, so this is just in case
            if initialList.count == 500 {
                let nextPageList = try await networker.getSeasonAnimeList(season: season, year: year, page: 2)
                initialList.append(contentsOf: nextPageList)
            }
            
            let animeList = initialList.filter { $0.node.rating != "rx" && $0.node.mediaType != "music" && $0.node.mediaType != "pv" }
            if season == .winter {
                winterItems = animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year }
                winterContinuingItems = animeList.filter { $0.node.startSeason?.season != season || $0.node.startSeason?.year != year }
            } else if season == .spring {
                springItems = animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year }
                springContinuingItems = animeList.filter { $0.node.startSeason?.season != season || $0.node.startSeason?.year != year }
            } else if season == .summer {
                summerItems = animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year }
                summerContinuingItems = animeList.filter { $0.node.startSeason?.season != season || $0.node.startSeason?.year != year }
            } else if season == .fall {
                fallItems = animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year }
                fallContinuingItems = animeList.filter { $0.node.startSeason?.season != season || $0.node.startSeason?.year != year }
            }
            loadingState = .idle
        } catch {
            // If 404 not found, usually means the season still has not been released yet
            // Ignore cancellation error, from deeplinking to another year and season
            if case NetworkError.notFound = error {
                if season == .winter {
                    isWinterUnreleased = true
                } else if season == .spring {
                    isSpringUnreleased = true
                } else if season == .summer {
                    isSummerUnreleased = true
                } else if season == .fall {
                    isFallUnreleased = true
                }
                loadingState = .idle
            } else if !Task.isCancelled && !(error is CancellationError) {
                loadingState = .error
            }
        }
    }
}

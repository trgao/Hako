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
    
    // Spring season variables
    @Published var springItems: [MALListAnime] = []
    @Published var springContinuingItems: [MALListAnime] = []
    
    // Summer season variables
    @Published var summerItems: [MALListAnime] = []
    @Published var summerContinuingItems: [MALListAnime] = []
    
    // Fall season variables
    @Published var fallItems: [MALListAnime] = []
    @Published var fallContinuingItems: [MALListAnime] = []
    
    // Common variables
    @Published var season = Constants.seasons[((Calendar(identifier: .gregorian).dateComponents([.month], from: .now).month ?? 9) - 1) / 3] // map the current month to the current season
    @Published var year = Constants.currentYear
    @Published var loadingState: LoadingEnum = .loading
    let networker = NetworkManager.shared
    
    // Check if the anime list for the current season is empty
    func isSeasonEmpty() -> Bool {
        return (season == .winter && winterItems.isEmpty) || (season == .spring && springItems.isEmpty) || (season == .summer && summerItems.isEmpty) || (season == .fall && fallItems.isEmpty)
    }
    
    // Check if the continuing series list for the current season is empty
    func isSeasonContinuingEmpty() -> Bool {
        return (season == .winter && winterContinuingItems.isEmpty) || (season == .spring && springContinuingItems.isEmpty) || (season == .summer && summerContinuingItems.isEmpty) || (season == .fall && fallContinuingItems.isEmpty)
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
            if case NetworkError.notFound = error {
                loadingState = .idle
            } else {
                loadingState = .error
            }
        }
    }
}

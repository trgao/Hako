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
    @Published var winterItems = [MALListAnime]()
    @Published var winterContinuingItems = [MALListAnime]()
    @Published var canLoadMoreWinterPages = true
    private var currentWinterPage = 1
    
    // Spring season variables
    @Published var springItems = [MALListAnime]()
    @Published var springContinuingItems = [MALListAnime]()
    @Published var canLoadMoreSpringPages = true
    private var currentSpringPage = 1
    
    // Summer season variables
    @Published var summerItems = [MALListAnime]()
    @Published var summerContinuingItems = [MALListAnime]()
    @Published var canLoadMoreSummerPages = true
    private var currentSummerPage = 1
    
    // Fall season variables
    @Published var fallItems = [MALListAnime]()
    @Published var fallContinuingItems = [MALListAnime]()
    @Published var canLoadMoreFallPages = true
    private var currentFallPage = 1
    
    // Common variables
    @Published var season = Constants.seasons[((Calendar(identifier: .gregorian).dateComponents([.month], from: .now).month ?? 9) - 1) / 3] // map the current month to the current season
    @Published var year = Constants.currentYear
    @Published var isLoading = true
    @Published var isLoadingError = false
    let networker = NetworkManager.shared
    
    // Check if the anime list for the current season is empty
    func isSeasonEmpty() -> Bool {
        return (season == .winter && winterItems.isEmpty) || (season == .spring && springItems.isEmpty) || (season == .summer && summerItems.isEmpty) || (season == .fall && fallItems.isEmpty)
    }
    
    // Check if the continuing series list for the current season is empty
    func isSeasonContinuingEmpty() -> Bool {
        return (season == .winter && winterContinuingItems.isEmpty) || (season == .spring && springContinuingItems.isEmpty) || (season == .summer && summerContinuingItems.isEmpty) || (season == .fall && fallContinuingItems.isEmpty)
    }
    
    // Check if the anime list for the current season should be refreshed
    func shouldRefresh() -> Bool {
        return (season == .winter && winterItems.isEmpty && canLoadMoreWinterPages) || (season == .spring && springItems.isEmpty && canLoadMoreSpringPages) || (season == .summer && summerItems.isEmpty && canLoadMoreSummerPages) || (season == .fall && fallItems.isEmpty && canLoadMoreFallPages)
    }
    
    // Get (season)Items variable for the current season
    func getCurrentSeasonItems() -> [MALListAnime] {
        switch season {
        case .winter: return winterItems
        case .spring: return springItems
        case .summer: return summerItems
        case .fall: return fallItems
        }
    }
    
    // Get (season)ContinuingItems variable for the current season
    func getCurrentSeasonContinuingItems() -> [MALListAnime] {
        switch season {
        case .winter: return winterContinuingItems
        case .spring: return springContinuingItems
        case .summer: return summerContinuingItems
        case .fall: return fallContinuingItems
        }
    }
    
    // Get canLoadMore(Season)Pages variable for the current season
    func getCurrentSeasonCanLoadMore() -> Bool {
        switch season {
        case .winter: return canLoadMoreWinterPages
        case .spring: return canLoadMoreSpringPages
        case .summer: return canLoadMoreSummerPages
        case .fall: return canLoadMoreFallPages
        }
    }
    
    // Get current(Season)Page variable for the current season
    private func getCurrentSeasonPage() -> Int {
        switch season {
        case .winter: return currentWinterPage
        case .spring: return currentSpringPage
        case .summer: return currentSummerPage
        case .fall: return currentFallPage
        }
    }
    
    // Update current(Season)Page variable for the current season
    private func updateCurrentSeasonPage(_ currentPage: Int) {
        switch season {
        case .winter: currentWinterPage = currentPage
        case .spring: currentSpringPage = currentPage
        case .summer: currentSummerPage = currentPage
        case .fall: currentFallPage = currentPage
        }
    }
    
    // Update canLoadMore(Season)Pages variable for the current season
    private func updateCurrentSeasonCanLoadMore(_ canLoadMorePages: Bool) {
        switch season {
        case .winter: canLoadMoreWinterPages = canLoadMorePages
        case .spring: canLoadMoreSpringPages = canLoadMorePages
        case .summer: canLoadMoreSummerPages = canLoadMorePages
        case .fall: canLoadMoreFallPages = canLoadMorePages
        }
    }
    
    // Refresh the current season list
    func refresh(_ clear: Bool = false) async {
        // Reset all lists if need to clear (to change year)
        if clear {
            winterItems = []
            winterContinuingItems = []
            currentWinterPage = 1
            canLoadMoreWinterPages = true
            
            springItems = []
            springContinuingItems = []
            currentSpringPage = 1
            canLoadMoreSpringPages = true
            
            summerItems = []
            summerContinuingItems = []
            currentSummerPage = 1
            canLoadMoreSummerPages = true
            
            fallItems = []
            fallContinuingItems = []
            currentFallPage = 1
            canLoadMoreFallPages = true
        }
        
        updateCurrentSeasonPage(1)
        updateCurrentSeasonCanLoadMore(true)
        isLoading = true
        isLoadingError = false
        do {
            let animeList = try await networker.getSeasonAnimeList(season: season, year: year, page: getCurrentSeasonPage()).filter { $0.node.rating != "rx" && $0.node.mediaType != "music" && $0.node.mediaType != "pv" }
            updateCurrentSeasonPage(2)
            updateCurrentSeasonCanLoadMore(animeList.count > 450)
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
        } catch {
            // If 404 not found, usually means the season still has not been released yet
            if case NetworkError.notFound = error {
                updateCurrentSeasonCanLoadMore(false)
            } else {
                isLoadingError = true
            }
        }
        isLoading = false
    }
    
    // Load more of the current season
    private func loadMore() async {
        // only load more when it is not loading and there are more pages to be loaded
        guard !isLoading && getCurrentSeasonCanLoadMore() else {
            return
        }
        
        // only load more when there are already items on the page
        guard !isSeasonEmpty() else {
            return
        }
        
        isLoading = true
        isLoadingError = false
        do {
            let animeList = try await networker.getSeasonAnimeList(season: season, year: year, page: getCurrentSeasonPage()).filter{ $0.node.rating != "rx" && $0.node.mediaType != "music" && $0.node.mediaType != "pv" }
            updateCurrentSeasonPage(getCurrentSeasonPage() + 1)
            updateCurrentSeasonCanLoadMore(animeList.count > 450)
            if season == .winter {
                winterItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year })
                winterContinuingItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season != season || $0.node.startSeason?.year != year })
            } else if season == .spring {
                springItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year })
                springContinuingItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season != season || $0.node.startSeason?.year != year })
            } else if season == .summer {
                summerItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year })
                summerContinuingItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season != season || $0.node.startSeason?.year != year })
            } else if season == .fall {
                fallItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year })
                fallContinuingItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season != season || $0.node.startSeason?.year != year })
            }
        } catch {
            // If 404 not found, usually means the season still has not been released yet
            if case NetworkError.notFound = error {
                updateCurrentSeasonCanLoadMore(false)
            } else {
                isLoadingError = true
            }
        }
        isLoading = false
    }
    
    // Load more items from current season when reaching the 4th last anime in list
    func loadMoreIfNeeded(index: Int) async {
        var thresholdIndex: Int?
        if season == .winter {
            thresholdIndex = winterItems.endIndex - 5
        } else if season == .spring {
            thresholdIndex = springItems.endIndex - 5
        } else if season == .summer {
            thresholdIndex = summerItems.endIndex - 5
        } else if season == .fall {
            thresholdIndex = fallItems.endIndex - 5
        }
        if index == thresholdIndex {
            await loadMore()
        }
    }
}

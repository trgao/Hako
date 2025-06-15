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
    @Published var isWinterLoading = false
    @Published var canLoadMoreWinterPages = true
    private var currentWinterPage = 1
    
    // Spring season variables
    @Published var springItems = [MALListAnime]()
    @Published var springContinuingItems = [MALListAnime]()
    @Published var isSpringLoading = false
    @Published var canLoadMoreSpringPages = true
    private var currentSpringPage = 1
    
    // Summer season variables
    @Published var summerItems = [MALListAnime]()
    @Published var summerContinuingItems = [MALListAnime]()
    @Published var isSummerLoading = false
    @Published var canLoadMoreSummerPages = true
    private var currentSummerPage = 1
    
    // Fall season variables
    @Published var fallItems = [MALListAnime]()
    @Published var fallContinuingItems = [MALListAnime]()
    @Published var isFallLoading = false
    @Published var canLoadMoreFallPages = true
    private var currentFallPage = 1
    
    // Common variables
    @Published var season = ["winter", "spring", "summer", "fall"][((Calendar(identifier: .gregorian).dateComponents([.month], from: .now).month ?? 9) - 1) / 3] // map the current month to the current season
    @Published var year = Calendar(identifier: .gregorian).dateComponents([.year], from: .now).year ?? 2001
    @Published var isLoadingError = false
    let networker = NetworkManager.shared
    
    // Check if the anime list for the current season is empty
    func isSeasonEmpty() -> Bool {
        return (season == "winter" && winterItems.isEmpty) || (season == "spring" && springItems.isEmpty) || (season == "summer" && summerItems.isEmpty) || (season == "fall" && fallItems.isEmpty)
    }
    
    // Check if the continuing series list for the current season is empty
    func isSeasonContinuingEmpty() -> Bool {
        return (season == "winter" && winterContinuingItems.isEmpty) || (season == "spring" && springContinuingItems.isEmpty) || (season == "summer" && summerContinuingItems.isEmpty) || (season == "fall" && fallContinuingItems.isEmpty)
    }
    
    // Check if the anime list for the current season should be refreshed
    func shouldRefresh() -> Bool {
        return (season == "winter" && winterItems.isEmpty && canLoadMoreWinterPages) || (season == "spring" && springItems.isEmpty && canLoadMoreSpringPages) || (season == "summer" && summerItems.isEmpty && canLoadMoreSummerPages) || (season == "fall" && fallItems.isEmpty && canLoadMoreFallPages)
    }
    
    // Get (season)Items variable for the current season
    func getCurrentSeasonItems() -> [MALListAnime] {
        if season == "winter" {
            return winterItems
        } else if season == "spring" {
            return springItems
        } else if season == "summer" {
            return summerItems
        } else if season == "fall" {
            return fallItems
        } else {
            // Should not reach here
            return []
        }
    }
    
    // Get (season)ContinuingItems variable for the current season
    func getCurrentSeasonContinuingItems() -> [MALListAnime] {
        if season == "winter" {
            return winterContinuingItems
        } else if season == "spring" {
            return springContinuingItems
        } else if season == "summer" {
            return summerContinuingItems
        } else if season == "fall" {
            return fallContinuingItems
        } else {
            // Should not reach here
            return []
        }
    }
    
    // Get is(Season)Loading variable for the current season
    func getCurrentSeasonLoading() -> Bool {
        if season == "winter" {
            return isWinterLoading
        } else if season == "spring" {
            return isSpringLoading
        } else if season == "summer" {
            return isSummerLoading
        } else if season == "fall" {
            return isFallLoading
        } else {
            // Should not reach here
            return false
        }
    }
    
    // Get canLoadMore(Season)Pages variable for the current season
    func getCurrentSeasonCanLoadMore() -> Bool {
        if season == "winter" {
            return canLoadMoreWinterPages
        } else if season == "spring" {
            return canLoadMoreSpringPages
        } else if season == "summer" {
            return canLoadMoreSummerPages
        } else if season == "fall" {
            return canLoadMoreFallPages
        } else {
            // Should not reach here
            return false
        }
    }
    
    // Get current(Season)Page variable for the current season
    private func getCurrentSeasonPage() -> Int {
        if season == "winter" {
            return currentWinterPage
        } else if season == "spring" {
            return currentSpringPage
        } else if season == "summer" {
            return currentSummerPage
        } else if season == "fall" {
            return currentFallPage
        } else {
            // Should not reach here
            return 1
        }
    }
    
    // Update current(Season)Page variable for the current season
    private func updateCurrentSeasonPage(_ currentPage: Int) {
        if season == "winter" {
            currentWinterPage = currentPage
        } else if season == "spring" {
            currentSpringPage = currentPage
        } else if season == "summer" {
            currentSummerPage = currentPage
        } else if season == "fall" {
            currentFallPage = currentPage
        }
    }
    
    // Update is(Season)Loading variable for the current season
    private func updateCurrentSeasonLoading(_ isLoading: Bool) {
        if season == "winter" {
            isWinterLoading = isLoading
        } else if season == "spring" {
            isSpringLoading = isLoading
        } else if season == "summer" {
            isSummerLoading = isLoading
        } else if season == "fall" {
            isFallLoading = isLoading
        }
    }
    
    // Update canLoadMore(Season)Pages variable for the current season
    private func updateCurrentSeasonCanLoadMore(_ canLoadMorePages: Bool) {
        if season == "winter" {
            canLoadMoreWinterPages = canLoadMorePages
        } else if season == "spring" {
            canLoadMoreSpringPages = canLoadMorePages
        } else if season == "summer" {
            canLoadMoreSummerPages = canLoadMorePages
        } else if season == "fall" {
            canLoadMoreFallPages = canLoadMorePages
        }
    }
    
    // Refresh the current season list
    func refresh(_ clear: Bool = false) async -> Void {
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
        updateCurrentSeasonLoading(true)
        updateCurrentSeasonCanLoadMore(false)
        isLoadingError = false
        do {
            let animeList = try await networker.getSeasonAnimeList(season: season, year: year, page: getCurrentSeasonPage())
            updateCurrentSeasonPage(2)
            updateCurrentSeasonCanLoadMore(animeList.count > 450)
            if season == "winter" {
                winterItems = animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year }
                winterContinuingItems = animeList.filter { $0.node.startSeason?.season != season || $0.node.startSeason?.year != year }
            } else if season == "spring" {
                springItems = animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year }
                springContinuingItems = animeList.filter { $0.node.startSeason?.season != season || $0.node.startSeason?.year != year }
            } else if season == "summer" {
                summerItems = animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year }
                summerContinuingItems = animeList.filter { $0.node.startSeason?.season != season || $0.node.startSeason?.year != year }
            } else if season == "fall" {
                fallItems = animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year }
                fallContinuingItems = animeList.filter { $0.node.startSeason?.season != season || $0.node.startSeason?.year != year }
            }
        } catch let error as NetworkError {
            // If 404 not found, usually means the season still has not been released yet
            if case NetworkError.notFound = error {
                updateCurrentSeasonCanLoadMore(false)
            } else {
                isLoadingError = true
            }
        } catch {
            isLoadingError = true
        }
        updateCurrentSeasonLoading(false)
    }
    
    // Load more of the current season
    private func loadMore() async -> Void {
        // only load more when it is not loading and there are more pages to be loaded
        guard !getCurrentSeasonLoading() && getCurrentSeasonCanLoadMore() else {
            return
        }
        
        // only load more when there are already items on the page
        guard !isSeasonEmpty() else {
            return
        }
        
        updateCurrentSeasonLoading(true)
        isLoadingError = false
        do {
            let animeList = try await networker.getSeasonAnimeList(season: season, year: year, page: getCurrentSeasonPage())
            updateCurrentSeasonPage(getCurrentSeasonPage() + 1)
            updateCurrentSeasonCanLoadMore(animeList.count > 450)
            if season == "winter" {
                winterItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year })
                winterContinuingItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season != season || $0.node.startSeason?.year != year })
            } else if season == "spring" {
                springItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year })
                springContinuingItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season != season || $0.node.startSeason?.year != year })
            } else if season == "summer" {
                summerItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year })
                summerContinuingItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season != season || $0.node.startSeason?.year != year })
            } else if season == "fall" {
                fallItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year })
                fallContinuingItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season != season || $0.node.startSeason?.year != year })
            }
        } catch let error as NetworkError {
            // If 404 not found, usually means the season still has not been released yet
            if case NetworkError.notFound = error {
                updateCurrentSeasonCanLoadMore(false)
            } else {
                isLoadingError = true
            }
        } catch {
            isLoadingError = true
        }
        updateCurrentSeasonLoading(false)
    }
    
    // Load more items from current season when reaching the 4th last anime in list
    func loadMoreIfNeeded(index: Int) async -> Void {
        if season == "winter" {
            let thresholdIndex = winterItems.index(winterItems.endIndex, offsetBy: -4)
            if index == thresholdIndex {
                return await loadMore()
            }
        } else if season == "spring" {
            let thresholdIndex = springItems.index(springItems.endIndex, offsetBy: -4)
            if index == thresholdIndex {
                return await loadMore()
            }
        } else if season == "summer" {
            let thresholdIndex = summerItems.index(summerItems.endIndex, offsetBy: -4)
            if index == thresholdIndex {
                return await loadMore()
            }
        } else if season == "fall" {
            let thresholdIndex = fallItems.index(fallItems.endIndex, offsetBy: -4)
            if index == thresholdIndex {
                return await loadMore()
            }
        }
    }
}

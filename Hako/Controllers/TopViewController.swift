//
//  TopViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import Foundation

@MainActor
class TopViewController: ObservableObject {
    // Anime list variables
    @Published var animeItems = [MALListAnime]()
    @Published var animeRankingType = "all"
    private var currentAnimePage = 1
    private var canLoadMoreAnimePages = true
    
    // Manga list variables
    @Published var mangaItems = [MALListManga]()
    @Published var mangaRankingType = "all"
    private var currentMangaPage = 1
    private var canLoadMoreMangaPages = true
    
    // Common variables
    @Published var isLoading = true
    @Published var isLoadingError = false
    @Published var type: TypeEnum = .anime
    let networker = NetworkManager.shared
    
    // Check if the current anime/manga list is empty
    func isItemsEmpty() -> Bool {
        return (type == .anime && animeItems.isEmpty) || (type == .manga && mangaItems.isEmpty)
    }
    
    // Check if the current anime/manga list should be refreshed
    func shouldRefresh() -> Bool {
        return (type == .anime && animeItems.isEmpty && canLoadMoreAnimePages) || (type == .manga && mangaItems.isEmpty && canLoadMoreMangaPages)
    }
    
    // Refresh both anime and manga list
    func refresh(_ refresh: Bool = false) async {
        isLoading = true
        isLoadingError = false
        
        if !refresh {
            animeItems = []
            mangaItems = []
        }
        
        // Refresh anime list
        currentAnimePage = 1
        canLoadMoreAnimePages = true
        do {
            let animeList = try await networker.getTopAnimeList(page: currentAnimePage, rankingType: animeRankingType).filter{ $0.node.rating != "rx" }
            currentAnimePage = 2
            canLoadMoreAnimePages = !(animeList.isEmpty)
            animeItems = animeList
        } catch {
            isLoadingError = true
        }
        
        // Refresh manga list
        currentMangaPage = 1
        canLoadMoreMangaPages = true
        do {
            let mangaList = try await networker.getTopMangaList(page: currentMangaPage, rankingType: mangaRankingType)
            currentMangaPage = 2
            canLoadMoreMangaPages = !(mangaList.isEmpty)
            mangaItems = mangaList
        } catch {
            isLoadingError = true
        }
        isLoading = false
    }
    
    // Load more of the current anime/manga list
    private func loadMore() async {
        if type == .anime {
            // only load more when it is not loading and there are more pages to be loaded
            guard !isLoading && canLoadMoreAnimePages else {
                return
            }
            
            // only load more when there are already items on the page
            guard animeItems.count > 0 else {
                return
            }
            
            isLoading = true
            isLoadingError = false
            do {
                let animeList = try await networker.getTopAnimeList(page: currentAnimePage, rankingType: animeRankingType).filter{ $0.node.rating != "rx" }
                currentAnimePage += 1
                canLoadMoreAnimePages = !(animeList.isEmpty)
                animeItems.append(contentsOf: animeList)
            } catch {
                isLoadingError = true
            }
            isLoading = false
        } else if type == .manga {
            // only load more when it is not loading and there are more pages to be loaded
            guard !isLoading && canLoadMoreMangaPages else {
                return
            }
            
            // only load more when there are already items on the page
            guard mangaItems.count > 0 else {
                return
            }
            
            isLoading = true
            isLoadingError = false
            do {
                let mangaList = try await networker.getTopMangaList(page: currentMangaPage, rankingType: mangaRankingType)
                currentMangaPage += 1
                canLoadMoreMangaPages = !(mangaList.isEmpty)
                mangaItems.append(contentsOf: mangaList)
            } catch {
                isLoadingError = true
            }
            isLoading = false
        }
    }
    
    // Load more anime when reaching the 4th last anime/manga in list
    func loadMoreIfNeeded(index: Int) async {
        if type == .anime {
            let thresholdIndex = animeItems.index(animeItems.endIndex, offsetBy: -4)
            if index == thresholdIndex {
                return await loadMore()
            }
        } else if type == .manga {
            let thresholdIndex = mangaItems.index(mangaItems.endIndex, offsetBy: -4)
            if index == thresholdIndex {
                return await loadMore()
            }
        }
    }
}

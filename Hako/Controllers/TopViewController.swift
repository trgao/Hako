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
    @Published var animeRankingType: RankingEnum = .all
    @Published var isAnimeLoadingError = false
    private var currentAnimePage = 1
    private var canLoadMoreAnimePages = true
    
    // Manga list variables
    @Published var mangaItems = [MALListManga]()
    @Published var mangaRankingType: RankingEnum = .all
    @Published var isMangaLoadingError = false
    private var currentMangaPage = 1
    private var canLoadMoreMangaPages = true
    
    @Published var type: TypeEnum = .anime
    @Published var isLoading = true
    private let networker = NetworkManager.shared
    
    // Check if the current anime/manga list is empty
    func isItemsEmpty() -> Bool {
        return (type == .anime && animeItems.isEmpty) || (type == .manga && mangaItems.isEmpty)
    }
    
    // Refresh anime list
    private func refreshAnime(_ clear: Bool = false) async {
        isLoading = true
        isAnimeLoadingError = false
        currentAnimePage = 1
        canLoadMoreAnimePages = true
        
        if clear {
            animeItems = []
        }
        
        do {
            let animeList = try await networker.getTopAnimeList(page: currentAnimePage, rankingType: animeRankingType).filter{ $0.node.rating != "rx" }
            currentAnimePage = 2
            canLoadMoreAnimePages = !(animeList.isEmpty)
            animeItems = animeList
        } catch {
            isAnimeLoadingError = true
        }
        
        isLoading = false
    }
    
    // Refresh manga list
    private func refreshManga(_ clear: Bool = false) async {
        isLoading = true
        isMangaLoadingError = false
        currentMangaPage = 1
        canLoadMoreMangaPages = true
        
        if clear {
            mangaItems = []
        }
        
        do {
            let mangaList = try await networker.getTopMangaList(page: currentMangaPage, rankingType: mangaRankingType)
            currentMangaPage = 2
            canLoadMoreMangaPages = !(mangaList.isEmpty)
            mangaItems = mangaList
        } catch {
            isMangaLoadingError = true
        }
        
        isLoading = false
    }
    
    // Refresh current list
    func refresh(_ clear: Bool = false) async {
        if type == .anime {
            await refreshAnime(clear)
        } else if type == .manga {
            await refreshManga(clear)
        }
    }
    
    // Load more of the current anime list
    private func loadMoreAnime() async {
        // only load more when it is not loading, page is not empty and there are more pages to be loaded
        guard !isLoading && !animeItems.isEmpty && canLoadMoreAnimePages else {
            return
        }
        
        isLoading = true
        isAnimeLoadingError = false
        do {
            let animeList = try await networker.getTopAnimeList(page: currentAnimePage, rankingType: animeRankingType).filter{ $0.node.rating != "rx" }
            currentAnimePage += 1
            canLoadMoreAnimePages = !(animeList.isEmpty)
            animeItems.append(contentsOf: animeList)
        } catch {
            isAnimeLoadingError = true
        }
        isLoading = false
    }
    
    // Load more of the current manga list
    private func loadMoreManga() async {
        // only load more when it is not loading, page is not empty and there are more pages to be loaded
        guard !isLoading && !mangaItems.isEmpty && canLoadMoreMangaPages else {
            return
        }
        
        isLoading = true
        isMangaLoadingError = false
        do {
            let mangaList = try await networker.getTopMangaList(page: currentMangaPage, rankingType: mangaRankingType)
            currentMangaPage += 1
            canLoadMoreMangaPages = !(mangaList.isEmpty)
            mangaItems.append(contentsOf: mangaList)
        } catch {
            isMangaLoadingError = true
        }
        isLoading = false
    }
    
    // Load more anime when reaching the 4th last anime/manga in list
    func loadMoreIfNeeded(index: Int) async {
        if type == .anime && index == animeItems.endIndex - 5 {
            await loadMoreAnime()
        } else if type == .manga && index == mangaItems.endIndex - 5 {
            await loadMoreManga()
        }
    }
}

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
    @Published var isAnimeLoading = true
    @Published var isAnimeLoadingError = false
    private var currentAnimePage = 1
    private var canLoadMoreAnimePages = true
    
    // Manga list variables
    @Published var mangaItems = [MALListManga]()
    @Published var mangaRankingType: RankingEnum = .all
    @Published var isMangaLoading = true
    @Published var isMangaLoadingError = false
    private var currentMangaPage = 1
    private var canLoadMoreMangaPages = true
    
    @Published var type: TypeEnum = .anime
    private let networker = NetworkManager.shared
    
    // Check if the current anime/manga list is loading
    func isLoading() -> Bool {
        return (type == .anime && isAnimeLoading) || (type == .manga && isMangaLoading)
    }
    
    // Check if the current anime/manga list is empty
    func isItemsEmpty() -> Bool {
        return (type == .anime && animeItems.isEmpty) || (type == .manga && mangaItems.isEmpty)
    }
    
    // Refresh anime list
    private func refreshAnime(_ refresh: Bool = false) async {
        isAnimeLoading = true
        isAnimeLoadingError = false
        currentAnimePage = 1
        canLoadMoreAnimePages = true
        
        if !refresh {
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
        
        isAnimeLoading = false
    }
    
    // Refresh manga list
    private func refreshManga(_ refresh: Bool = false) async {
        isMangaLoading = true
        isMangaLoadingError = false
        currentMangaPage = 1
        canLoadMoreMangaPages = true
        
        if !refresh {
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
        
        isMangaLoading = false
    }
    
    // Refresh current list
    func refresh(_ refresh: Bool = false) async {
        if type == .anime {
            await refreshAnime(refresh)
        } else if type == .manga {
            await refreshManga(refresh)
        }
    }
    
    // Load more of the current anime/manga list
    private func loadMore() async {
        if type == .anime {
            // only load more when it is not loading and there are more pages to be loaded
            guard !isAnimeLoading && canLoadMoreAnimePages else {
                return
            }
            
            // only load more when there are already items on the page
            guard animeItems.count > 0 else {
                return
            }
            
            isAnimeLoading = true
            isAnimeLoadingError = false
            do {
                let animeList = try await networker.getTopAnimeList(page: currentAnimePage, rankingType: animeRankingType).filter{ $0.node.rating != "rx" }
                currentAnimePage += 1
                canLoadMoreAnimePages = !(animeList.isEmpty)
                animeItems.append(contentsOf: animeList)
            } catch {
                isAnimeLoadingError = true
            }
            isAnimeLoading = false
        } else if type == .manga {
            // only load more when it is not loading and there are more pages to be loaded
            guard !isMangaLoading && canLoadMoreMangaPages else {
                return
            }
            
            // only load more when there are already items on the page
            guard mangaItems.count > 0 else {
                return
            }
            
            isMangaLoading = true
            isMangaLoadingError = false
            do {
                let mangaList = try await networker.getTopMangaList(page: currentMangaPage, rankingType: mangaRankingType)
                currentMangaPage += 1
                canLoadMoreMangaPages = !(mangaList.isEmpty)
                mangaItems.append(contentsOf: mangaList)
            } catch {
                isMangaLoadingError = true
            }
            isMangaLoading = false
        }
    }
    
    // Load more anime when reaching the 4th last anime/manga in list
    func loadMoreIfNeeded(index: Int) async {
        if type == .anime && index == animeItems.endIndex - 5 {
            await loadMore()
        } else if type == .manga && index == mangaItems.endIndex - 5 {
            await loadMore()
        }
    }
}

//
//  MyListViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import Foundation

@MainActor
class MyListViewController: ObservableObject {
    // Anime list variables
    @Published var animeItems = [MALListAnime]()
    @Published var isAnimeLoading = true
    @Published var animeStatus: StatusEnum = .watching
    @Published var animeSort = "anime_title"
    @Published var animeLoadId = UUID()
    private var currentAnimePage = 1
    var canLoadMoreAnimePages = true
    
    // Manga list variables
    @Published var mangaItems = [MALListManga]()
    @Published var isMangaLoading = true
    @Published var mangaStatus: StatusEnum = .reading
    @Published var mangaSort = "manga_title"
    @Published var mangaLoadId = UUID()
    private var currentMangaPage = 1
    var canLoadMoreMangaPages = true
    
    // Common variables
    @Published var isLoading = false
    @Published var isLoadingError = false
    @Published var isEditError = false
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
    
    func updateAnime(index: Int, id: Int, listStatus: MyListStatus) async {
        isLoading = true
        do {
            try await networker.editUserAnime(id: id, listStatus: listStatus)
            animeItems[index].listStatus = listStatus
        } catch {
            isEditError = true
        }
        isLoading = false
    }
    
    func updateManga(index: Int, id: Int, listStatus: MyListStatus) async {
        isLoading = true
        do {
            try await networker.editUserManga(id: id, listStatus: listStatus)
            mangaItems[index].listStatus = listStatus
        } catch {
            isEditError = true
        }
        isLoading = false
    }
    
    // Refresh anime list
    func refreshAnime(_ refresh: Bool = false) async {
        animeLoadId = UUID()
        isLoadingError = false
        currentAnimePage = 1
        canLoadMoreAnimePages = false
        if refresh {
            isLoading = true
        } else {
            animeItems = []
            isAnimeLoading = true
        }
        do {
            let animeList = try await networker.getUserAnimeList(page: currentAnimePage, status: animeStatus, sort: animeSort)
            
            currentAnimePage = 2
            canLoadMoreAnimePages = animeList.count > 20
            animeItems = animeList
        } catch {
            isLoadingError = true
        }
        if refresh {
            isLoading = false
        } else {
            isAnimeLoading = false
        }
    }
    
    // Refresh manga list
    func refreshManga(_ refresh: Bool = false) async {
        mangaLoadId = UUID()
        isLoadingError = false
        currentMangaPage = 1
        canLoadMoreMangaPages = false
        if refresh {
            isLoading = true
        } else {
            mangaItems = []
            isMangaLoading = true
        }
        do {
            let mangaList = try await networker.getUserMangaList(page: currentMangaPage, status: mangaStatus, sort: mangaSort)
            
            currentMangaPage = 2
            canLoadMoreMangaPages = mangaList.count > 20
            mangaItems = mangaList
        } catch {
            isLoadingError = true
        }
        if refresh {
            isLoading = false
        } else {
            isMangaLoading = false
        }
    }
    
    // Refresh both anime and manga list
    func refresh(_ refresh: Bool = false) async {
        await refreshAnime(refresh)
        await refreshManga(refresh)
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
            isLoadingError = false
            do {
                let animeList = try await networker.getUserAnimeList(page: currentAnimePage, status: animeStatus, sort: animeSort)
                
                currentAnimePage += 1
                canLoadMoreAnimePages = animeList.count > 20
                animeItems.append(contentsOf: animeList)
            } catch {
                isLoadingError = true
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
            isLoadingError = false
            do {
                let mangaList = try await networker.getUserMangaList(page: currentMangaPage, status: mangaStatus, sort: mangaSort)
                
                currentMangaPage += 1
                canLoadMoreMangaPages = mangaList.count > 20
                mangaItems.append(contentsOf: mangaList)
            } catch {
                isLoadingError = true
            }
            isMangaLoading = false
        }
    }
    
    // Load more anime when reaching the 4th last anime/manga in list
    func loadMoreIfNeeded(index: Int) async {
        var thresholdIndex: Int?
        if type == .anime {
            thresholdIndex = animeItems.index(animeItems.endIndex, offsetBy: -4)
        } else if type == .manga {
            thresholdIndex = mangaItems.index(mangaItems.endIndex, offsetBy: -4)
        }
        if index == thresholdIndex {
            return await loadMore()
        }
    }
}

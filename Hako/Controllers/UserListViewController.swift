//
//  UserListViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import Foundation

@MainActor
class UserListViewController: ObservableObject {
    // Anime list variables
    @Published var animeItems = [MALListAnime]()
    @Published var isAnimeLoading = true
    @Published var isAnimeLoadingError = false
    @Published var animeStatus: StatusEnum = .watching
    @Published var animeSort: SortEnum = .animeTitle
    @Published var isAnimePrivate = false
    private var currentAnimePage = 1
    private var canLoadMoreAnimePages = true
    
    // Manga list variables
    @Published var mangaItems = [MALListManga]()
    @Published var isMangaLoading = true
    @Published var isMangaLoadingError = false
    @Published var mangaStatus: StatusEnum = .reading
    @Published var mangaSort: SortEnum = .mangaTitle
    @Published var isMangaPrivate = false
    private var currentMangaPage = 1
    private var canLoadMoreMangaPages = true
    
    // Common variables
    @Published var isRefreshLoading = false
    @Published var isEditError = false
    @Published var type: TypeEnum = .anime
    private let user: String
    private let networker = NetworkManager.shared
    
    init(user: String) {
        self.user = user
    }
    
    // Check if the current anime/manga list is loading
    func isLoading() -> Bool {
        return (type == .anime && isAnimeLoading) || (type == .manga && isMangaLoading) || isRefreshLoading
    }
    
    // Check if the current anime/manga list is empty
    func isItemsEmpty() -> Bool {
        return (type == .anime && animeItems.isEmpty) || (type == .manga && mangaItems.isEmpty)
    }
    
    func updateAnime(index: Int, id: Int, listStatus: MyListStatus) async {
        isRefreshLoading = true
        do {
            try await networker.editUserAnime(id: id, listStatus: listStatus)
            animeItems[index].listStatus = listStatus
        } catch {
            isEditError = true
        }
        isRefreshLoading = false
    }
    
    func updateManga(index: Int, id: Int, listStatus: MyListStatus) async {
        isRefreshLoading = true
        do {
            try await networker.editUserManga(id: id, listStatus: listStatus)
            mangaItems[index].listStatus = listStatus
        } catch {
            isEditError = true
        }
        isRefreshLoading = false
    }
    
    // Refresh anime list
    private func refreshAnime(_ clear: Bool = false) async {
        isAnimePrivate = false
        isAnimeLoadingError = false
        currentAnimePage = 1
        canLoadMoreAnimePages = false
        let listLoading = clear || animeItems.isEmpty
        if listLoading {
            animeItems = []
            isAnimeLoading = true
        } else {
            isRefreshLoading = true
        }
        do {
            let animeList = try await networker.getUserAnimeList(user: user, page: currentAnimePage, status: animeStatus, sort: animeSort)
            currentAnimePage = 2
            canLoadMoreAnimePages = animeList.count > 20
            animeItems = animeList
        } catch {
            // If 403 unauthorized and not current user, it means they have privated their list
            if case NetworkError.badStatusCode(403) = error, user != "@me" {
                isAnimePrivate = true
            } else {
                isAnimeLoadingError = true
            }
        }
        if listLoading {
            isAnimeLoading = false
        } else {
            isRefreshLoading = false
        }
    }
    
    // Refresh manga list
    private func refreshManga(_ clear: Bool = false) async {
        isMangaPrivate = false
        isMangaLoadingError = false
        currentMangaPage = 1
        canLoadMoreMangaPages = false
        let listLoading = clear || mangaItems.isEmpty
        if listLoading {
            mangaItems = []
            isMangaLoading = true
        } else if mangaItems.isEmpty {
            isMangaLoading = true
        } else {
            isRefreshLoading = true
        }
        do {
            let mangaList = try await networker.getUserMangaList(user: user, page: currentMangaPage, status: mangaStatus, sort: mangaSort)
            currentMangaPage = 2
            canLoadMoreMangaPages = mangaList.count > 20
            mangaItems = mangaList
        } catch {
            // If 403 unauthorized and not current user, it means they have privated their list
            if case NetworkError.badStatusCode(403) = error, user != "@me" {
                isMangaPrivate = true
            } else {
                isMangaLoadingError = true
            }
        }
        if listLoading {
            isMangaLoading = false
        } else {
            isRefreshLoading = false
        }
    }
    
    // Refresh current list
    func refresh(_ clear: Bool = false) async {
        if type == .anime {
            await refreshAnime(clear)
        } else if type == .manga {
            await refreshManga(clear)
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
                let animeList = try await networker.getUserAnimeList(user: user, page: currentAnimePage, status: animeStatus, sort: animeSort)
                currentAnimePage += 1
                canLoadMoreAnimePages = animeList.count > 20
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
                let mangaList = try await networker.getUserMangaList(user: user, page: currentMangaPage, status: mangaStatus, sort: mangaSort)
                currentMangaPage += 1
                canLoadMoreMangaPages = mangaList.count > 20
                mangaItems.append(contentsOf: mangaList)
            } catch {
                isMangaLoadingError = true
            }
            isMangaLoading = false
        }
    }
    
    // Load more anime/manga when reaching the 4th last anime/manga in list
    func loadMoreIfNeeded(index: Int) async {
        if type == .anime && index == animeItems.endIndex - 5 {
            await loadMore()
        } else if type == .manga && index == mangaItems.endIndex - 5 {
            await loadMore()
        }
    }
}

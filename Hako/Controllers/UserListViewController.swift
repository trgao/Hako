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
    @Published var isAnimeLoading = true
    @Published var isAnimeLoadingError = false
    @Published var animeStatus: StatusEnum = .watching
    @Published var animeSort: SortEnum = .animeTitle
    @Published var isAnimePrivate = false
    
    @Published var allAnimeItems: [MALListAnime] = []
    private var currentAllAnimePage = 1
    private var canLoadMoreAllAnimePages = true
    
    @Published var watchingAnimeItems: [MALListAnime] = []
    private var currentWatchingAnimePage = 1
    private var canLoadMoreWatchingAnimePages = true
    
    @Published var completedAnimeItems: [MALListAnime] = []
    private var currentCompletedAnimePage = 1
    private var canLoadMoreCompletedAnimePages = true
    
    @Published var onHoldAnimeItems: [MALListAnime] = []
    private var currentOnHoldAnimePage = 1
    private var canLoadMoreOnHoldAnimePages = true
    
    @Published var droppedAnimeItems: [MALListAnime] = []
    private var currentDroppedAnimePage = 1
    private var canLoadMoreDroppedAnimePages = true
    
    @Published var planToWatchAnimeItems: [MALListAnime] = []
    private var currentPlanToWatchAnimePage = 1
    private var canLoadMorePlanToWatchAnimePages = true
    
    // Manga list variables
    @Published var isMangaLoading = true
    @Published var isMangaLoadingError = false
    @Published var mangaStatus: StatusEnum = .reading
    @Published var mangaSort: SortEnum = .mangaTitle
    @Published var isMangaPrivate = false
    
    @Published var allMangaItems: [MALListManga] = []
    private var currentAllMangaPage = 1
    private var canLoadMoreAllMangaPages = true
    
    @Published var readingMangaItems: [MALListManga] = []
    private var currentReadingMangaPage = 1
    private var canLoadMoreReadingMangaPages = true
    
    @Published var completedMangaItems: [MALListManga] = []
    private var currentCompletedMangaPage = 1
    private var canLoadMoreCompletedMangaPages = true
    
    @Published var onHoldMangaItems: [MALListManga] = []
    private var currentOnHoldMangaPage = 1
    private var canLoadMoreOnHoldMangaPages = true
    
    @Published var droppedMangaItems: [MALListManga] = []
    private var currentDroppedMangaPage = 1
    private var canLoadMoreDroppedMangaPages = true
    
    @Published var planToReadMangaItems: [MALListManga] = []
    private var currentPlanToReadMangaPage = 1
    private var canLoadMorePlanToReadMangaPages = true
    
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
    
    // Check if the current anime list is empty
    func isAnimeItemsEmpty() -> Bool {
        return (animeStatus == .none && allAnimeItems.isEmpty) || (animeStatus == .watching && watchingAnimeItems.isEmpty) || (animeStatus == .completed && completedAnimeItems.isEmpty) || (animeStatus == .onHold && onHoldAnimeItems.isEmpty) || (animeStatus == .dropped && droppedAnimeItems.isEmpty) || (animeStatus == .planToWatch && planToWatchAnimeItems.isEmpty)
    }
    
    // Check if the current manga list is empty
    func isMangaItemsEmpty() -> Bool {
        return (mangaStatus == .none && allMangaItems.isEmpty) || (mangaStatus == .reading && readingMangaItems.isEmpty) || (mangaStatus == .completed && completedMangaItems.isEmpty) || (mangaStatus == .onHold && onHoldMangaItems.isEmpty) || (mangaStatus == .dropped && droppedMangaItems.isEmpty) || (mangaStatus == .planToRead && planToReadMangaItems.isEmpty)
    }
    
    // Check if the current anime/manga list is empty
    func isItemsEmpty() -> Bool {
        return (type == .anime && isAnimeItemsEmpty()) || (type == .manga &&  isMangaItemsEmpty())
    }
    
    // Check if the current anime/manga list should be refreshed
    func shouldRefresh() -> Bool {
        return (type == .anime && ((animeStatus == .none && (!allAnimeItems.isEmpty || canLoadMoreAllAnimePages)) || (animeStatus == .watching && (!watchingAnimeItems.isEmpty || canLoadMoreWatchingAnimePages)) || (animeStatus == .completed && (!completedAnimeItems.isEmpty || canLoadMoreCompletedAnimePages)) || (animeStatus == .onHold && (!onHoldAnimeItems.isEmpty || canLoadMoreOnHoldAnimePages)) || (animeStatus == .dropped && (!droppedAnimeItems.isEmpty || canLoadMoreDroppedAnimePages)) || (animeStatus == .planToWatch && (!planToWatchAnimeItems.isEmpty || canLoadMorePlanToWatchAnimePages)))) || (type == .manga && ((mangaStatus == .none && (!allMangaItems.isEmpty || canLoadMoreAllMangaPages)) || (mangaStatus == .reading && (!readingMangaItems.isEmpty || canLoadMoreReadingMangaPages)) || (mangaStatus == .completed && (!completedMangaItems.isEmpty || canLoadMoreCompletedMangaPages)) || (mangaStatus == .onHold && (!onHoldMangaItems.isEmpty || canLoadMoreOnHoldMangaPages)) || (mangaStatus == .dropped && (!droppedMangaItems.isEmpty || canLoadMoreDroppedMangaPages)) || (mangaStatus == .planToRead && (!planToReadMangaItems.isEmpty || canLoadMorePlanToReadMangaPages))))
    }
    
    // Update anime item list status for current anime status
    func updateAnimeItemListStatus(_ index: Int, _ listStatus: MyListStatus) {
        switch animeStatus {
        case .none: allAnimeItems[index].listStatus = listStatus
        case .watching: watchingAnimeItems[index].listStatus = listStatus
        case .completed: completedAnimeItems[index].listStatus = listStatus
        case .onHold: onHoldAnimeItems[index].listStatus = listStatus
        case .dropped: droppedAnimeItems[index].listStatus = listStatus
        case .planToWatch: planToWatchAnimeItems[index].listStatus = listStatus
        default: return
        }
    }
    
    // Update manga item list status for current anime status
    func updateMangaItemListStatus(_ index: Int, _ listStatus: MyListStatus) {
        switch mangaStatus {
        case .none: allMangaItems[index].listStatus = listStatus
        case .reading: readingMangaItems[index].listStatus = listStatus
        case .completed: completedMangaItems[index].listStatus = listStatus
        case .onHold: onHoldMangaItems[index].listStatus = listStatus
        case .dropped: droppedMangaItems[index].listStatus = listStatus
        case .planToRead: planToReadMangaItems[index].listStatus = listStatus
        default: return
        }
    }
    
    // Remove item from anime list
    func removeAnimeItem(_ index: Int) {
        switch animeStatus {
        case .none: allAnimeItems.remove(at: index)
        case .watching: watchingAnimeItems.remove(at: index)
        case .completed: completedAnimeItems.remove(at: index)
        case .onHold: onHoldAnimeItems.remove(at: index)
        case .dropped: droppedAnimeItems.remove(at: index)
        case .planToWatch: planToWatchAnimeItems.remove(at: index)
        default: return // should not reach here
        }
    }
    
    // Remove item from manga list
    func removeMangaItem(_ index: Int) {
        switch mangaStatus {
        case .none: allMangaItems.remove(at: index)
        case .reading: readingMangaItems.remove(at: index)
        case .completed: completedMangaItems.remove(at: index)
        case .onHold: onHoldMangaItems.remove(at: index)
        case .dropped: droppedMangaItems.remove(at: index)
        case .planToRead: planToReadMangaItems.remove(at: index)
        default: return // should not reach here
        }
    }
    
    // Replace (status)AnimeItems variable for the current anime status
    func replaceCurrentAnimeItems(_ list: [MALListAnime]) {
        switch animeStatus {
        case .none: allAnimeItems = list
        case .watching: watchingAnimeItems = list
        case .completed: completedAnimeItems = list
        case .onHold: onHoldAnimeItems = list
        case .dropped: droppedAnimeItems = list
        case .planToWatch: planToWatchAnimeItems = list
        default: return // should not reach here
        }
    }
    
    // Replace (status)MangaItems variable for the current manga status
    func replaceCurrentMangaItems(_ list: [MALListManga]) {
        switch mangaStatus {
        case .none: allMangaItems = list
        case .reading: readingMangaItems = list
        case .completed: completedMangaItems = list
        case .onHold: onHoldMangaItems = list
        case .dropped: droppedMangaItems = list
        case .planToRead: planToReadMangaItems = list
        default: return // should not reach here
        }
    }
    
    // Append items to (status)AnimeItems variable for the current anime status
    private func appendCurrentAnimeItems(_ list: [MALListAnime]) {
        switch animeStatus {
        case .none: allAnimeItems.append(contentsOf: list)
        case .watching: watchingAnimeItems.append(contentsOf: list)
        case .completed: completedAnimeItems.append(contentsOf: list)
        case .onHold: onHoldAnimeItems.append(contentsOf: list)
        case .dropped: droppedAnimeItems.append(contentsOf: list)
        case .planToWatch: planToWatchAnimeItems.append(contentsOf: list)
        default: return // should not reach here
        }
    }
    
    // Append items to (status)MangaItems variable for the current manga status
    private func appendCurrentMangaItems(_ list: [MALListManga]) {
        switch mangaStatus {
        case .none: allMangaItems.append(contentsOf: list)
        case .reading: readingMangaItems.append(contentsOf: list)
        case .completed: completedMangaItems.append(contentsOf: list)
        case .onHold: onHoldMangaItems.append(contentsOf: list)
        case .dropped: droppedMangaItems.append(contentsOf: list)
        case .planToRead: planToReadMangaItems.append(contentsOf: list)
        default: return // should not reach here
        }
    }
    
    // Get canLoadMore(Status)AnimePages variable for the current anime status
    private func getCurrentAnimeCanLoadMore() -> Bool {
        switch animeStatus {
        case .none: return canLoadMoreAllAnimePages
        case .watching: return canLoadMoreWatchingAnimePages
        case .completed: return canLoadMoreCompletedAnimePages
        case .onHold: return canLoadMoreOnHoldAnimePages
        case .dropped: return canLoadMoreDroppedAnimePages
        case .planToWatch: return canLoadMorePlanToWatchAnimePages
        default: return false // should not reach here
        }
    }
    
    // Get canLoadMore(Status)MangaPages variable for the current manga status
    private func getCurrentMangaCanLoadMore() -> Bool {
        switch animeStatus {
        case .none: return canLoadMoreAllMangaPages
        case .reading: return canLoadMoreReadingMangaPages
        case .completed: return canLoadMoreCompletedMangaPages
        case .onHold: return canLoadMoreOnHoldMangaPages
        case .dropped: return canLoadMoreDroppedMangaPages
        case .planToRead: return canLoadMorePlanToReadMangaPages
        default: return false // should not reach here
        }
    }
    
    // Update canLoadMore(Status)AnimePages variable for the current anime status
    private func updateCurrentAnimeCanLoadMore(_ canLoadMorePages: Bool) {
        switch animeStatus {
        case .none: canLoadMoreAllAnimePages = canLoadMorePages
        case .watching: canLoadMoreWatchingAnimePages = canLoadMorePages
        case .completed: canLoadMoreCompletedAnimePages = canLoadMorePages
        case .onHold: canLoadMoreOnHoldAnimePages = canLoadMorePages
        case .dropped: canLoadMoreDroppedAnimePages = canLoadMorePages
        case .planToWatch: canLoadMorePlanToWatchAnimePages = canLoadMorePages
        default: return
        }
    }
    
    // Update canLoadMore(Status)MangaPages variable for the current manga status
    private func updateCurrentMangaCanLoadMore(_ canLoadMorePages: Bool) {
        switch mangaStatus {
        case .none: canLoadMoreAllMangaPages = canLoadMorePages
        case .reading: canLoadMoreReadingMangaPages = canLoadMorePages
        case .completed: canLoadMoreCompletedMangaPages = canLoadMorePages
        case .onHold: canLoadMoreOnHoldMangaPages = canLoadMorePages
        case .dropped: canLoadMoreDroppedMangaPages = canLoadMorePages
        case .planToRead: canLoadMorePlanToReadMangaPages = canLoadMorePages
        default: return
        }
    }
    
    // Get current(Status)AnimePage variable for the current anime status
    private func getCurrentAnimePage() -> Int {
        switch animeStatus {
        case .none: return currentAllAnimePage
        case .watching: return currentWatchingAnimePage
        case .completed: return currentCompletedAnimePage
        case .onHold: return currentOnHoldAnimePage
        case .dropped: return currentDroppedAnimePage
        case .planToWatch: return currentPlanToWatchAnimePage
        default: return 1 // should not reach here
        }
    }
    
    // Get current(Status)MangaPage variable for the current manga status
    private func getCurrentMangaPage() -> Int {
        switch mangaStatus {
        case .none: return currentAllMangaPage
        case .reading: return currentReadingMangaPage
        case .completed: return currentCompletedMangaPage
        case .onHold: return currentOnHoldMangaPage
        case .dropped: return currentDroppedMangaPage
        case .planToRead: return currentPlanToReadMangaPage
        default: return 1 // should not reach here
        }
    }
    
    // Update current(Status)AnimePage variable for the current anime status
    private func updateCurrentAnimePage(_ currentPage: Int) {
        switch animeStatus {
        case .none: currentAllAnimePage = currentPage
        case .watching: currentWatchingAnimePage = currentPage
        case .completed: currentCompletedAnimePage = currentPage
        case .onHold: currentOnHoldAnimePage = currentPage
        case .dropped: currentDroppedAnimePage = currentPage
        case .planToWatch: currentPlanToWatchAnimePage = currentPage
        default: return // should not reach here
        }
    }
    
    // Update current(Status)MangaPage variable for the current manga status
    private func updateCurrentMangaPage(_ currentPage: Int) {
        switch mangaStatus {
        case .none: currentAllMangaPage = currentPage
        case .reading: currentReadingMangaPage = currentPage
        case .completed: currentCompletedMangaPage = currentPage
        case .onHold: currentOnHoldMangaPage = currentPage
        case .dropped: currentDroppedMangaPage = currentPage
        case .planToRead: currentPlanToReadMangaPage = currentPage
        default: return // should not reach here
        }
    }
    
    func updateAnime(index: Int, id: Int, listStatus: MyListStatus) async {
        isRefreshLoading = true
        do {
            try await networker.editUserAnime(id: id, listStatus: listStatus)
            updateAnimeItemListStatus(index, listStatus)
        } catch {
            isEditError = true
        }
        isRefreshLoading = false
    }
    
    func updateManga(index: Int, id: Int, listStatus: MyListStatus) async {
        isRefreshLoading = true
        do {
            try await networker.editUserManga(id: id, listStatus: listStatus)
            updateMangaItemListStatus(index, listStatus)
        } catch {
            isEditError = true
        }
        isRefreshLoading = false
    }
    
    // Refresh anime list
    private func refreshAnime(_ clear: Bool = false) async {
        isAnimePrivate = false
        isAnimeLoadingError = false
        updateCurrentAnimePage(1)
        updateCurrentAnimeCanLoadMore(true)
        let listLoading = clear || isAnimeItemsEmpty()
        if clear {
            allAnimeItems = []
            watchingAnimeItems = []
            completedAnimeItems = []
            onHoldAnimeItems = []
            droppedAnimeItems = []
            planToWatchAnimeItems = []
            isAnimeLoading = true
        } else if isAnimeItemsEmpty() {
            isAnimeLoading = true
        } else {
            isRefreshLoading = true
        }
        do {
            let animeList = try await networker.getUserAnimeList(user: user, page: getCurrentAnimePage(), status: animeStatus, sort: animeSort)
            updateCurrentAnimePage(2)
            updateCurrentAnimeCanLoadMore(animeList.count > 20)
            replaceCurrentAnimeItems(animeList)
        } catch {
            // If 403 unauthorized and not current user, it means they have privated their list
            if case NetworkError.badStatusCode(403) = error, user != "@me" {
                isAnimePrivate = true
                updateCurrentAnimeCanLoadMore(false)
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
        updateCurrentMangaPage(1)
        updateCurrentMangaCanLoadMore(true)
        let listLoading = clear || isMangaItemsEmpty()
        if clear {
            allMangaItems = []
            readingMangaItems = []
            completedMangaItems = []
            onHoldMangaItems = []
            droppedMangaItems = []
            planToReadMangaItems = []
            isMangaLoading = true
        } else if isMangaItemsEmpty() {
            isMangaLoading = true
        } else {
            isRefreshLoading = true
        }
        do {
            let mangaList = try await networker.getUserMangaList(user: user, page: getCurrentMangaPage(), status: mangaStatus, sort: mangaSort)
            updateCurrentMangaPage(2)
            updateCurrentMangaCanLoadMore(mangaList.count > 20)
            replaceCurrentMangaItems(mangaList)
        } catch {
            // If 403 unauthorized and not current user, it means they have privated their list
            if case NetworkError.badStatusCode(403) = error, user != "@me" {
                isMangaPrivate = true
                updateCurrentMangaCanLoadMore(false)
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
    
    // Load more of the current anime list
    private func loadMoreAnime() async {
        // only load more when it is not loading and there are more pages to be loaded
        guard !isAnimeLoading && !isAnimeItemsEmpty() && getCurrentAnimeCanLoadMore() else {
            return
        }
        
        isAnimeLoading = true
        isAnimeLoadingError = false
        do {
            let animeList = try await networker.getUserAnimeList(user: user, page: getCurrentAnimePage(), status: animeStatus, sort: animeSort)
            updateCurrentAnimePage(getCurrentAnimePage() + 1)
            updateCurrentAnimeCanLoadMore(animeList.count > 20)
            appendCurrentAnimeItems(animeList)
        } catch {
            isAnimeLoadingError = true
        }
        isAnimeLoading = false
    }
    
    // Load more of the current manga list
    private func loadMoreManga() async {
        // only load more when it is not loading and there are more pages to be loaded
        guard !isMangaLoading && !isMangaItemsEmpty() && getCurrentMangaCanLoadMore() else {
            return
        }
        
        isMangaLoading = true
        isMangaLoadingError = false
        do {
            let mangaList = try await networker.getUserMangaList(user: user, page: getCurrentMangaPage(), status: mangaStatus, sort: mangaSort)
            updateCurrentMangaPage(getCurrentMangaPage() + 1)
            updateCurrentMangaCanLoadMore(mangaList.count > 20)
            appendCurrentMangaItems(mangaList)
        } catch {
            isMangaLoadingError = true
        }
        isMangaLoading = false
    }
    
    // Load more anime/manga when reaching the 4th last anime/manga in list
    func loadMoreIfNeeded(index: Int) async {
        if type == .anime {
            var thresholdIndex: Int?
            if animeStatus == .none {
                thresholdIndex = allAnimeItems.endIndex - 5
            } else if animeStatus == .watching {
                thresholdIndex = watchingAnimeItems.endIndex - 5
            } else if animeStatus == .completed {
                thresholdIndex = completedAnimeItems.endIndex - 5
            } else if animeStatus == .onHold {
                thresholdIndex = onHoldAnimeItems.endIndex - 5
            } else if animeStatus == .dropped {
                thresholdIndex = droppedAnimeItems.endIndex - 5
            } else if animeStatus == .planToWatch {
                thresholdIndex = planToWatchAnimeItems.endIndex - 5
            }
            if index == thresholdIndex {
                await loadMoreAnime()
            }
        } else if type == .manga {
            var thresholdIndex: Int?
            if mangaStatus == .none {
                thresholdIndex = allMangaItems.endIndex - 5
            } else if mangaStatus == .reading {
                thresholdIndex = readingMangaItems.endIndex - 5
            } else if mangaStatus == .completed {
                thresholdIndex = completedMangaItems.endIndex - 5
            } else if mangaStatus == .onHold {
                thresholdIndex = onHoldMangaItems.endIndex - 5
            } else if mangaStatus == .dropped {
                thresholdIndex = droppedMangaItems.endIndex - 5
            } else if mangaStatus == .planToRead {
                thresholdIndex = planToReadMangaItems.endIndex - 5
            }
            if index == thresholdIndex {
                await loadMoreManga()
            }
        }
    }
}

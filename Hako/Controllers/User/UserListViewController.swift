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
    @Published var animeStatus: StatusEnum = .watching
    @Published var animeSort: SortEnum = .animeTitle
    @Published var isAnimePrivate = false
    @Published private(set) var animeLists: [StatusEnum: ListState<MALListAnime>] = [:]

    // Manga list variables
    @Published var mangaStatus: StatusEnum = .reading
    @Published var mangaSort: SortEnum = .mangaTitle
    @Published var isMangaPrivate = false
    @Published private(set) var mangaLists: [StatusEnum: ListState<MALListManga>] = [:]

    // Common variables
    @Published var type: TypeEnum = .anime
    @Published var loadingState: LoadingEnum = .loading
    @Published var isUserNotFound = false
    @Published var isRefreshLoading = false
    @Published var isEditError = false
    private let user: String
    private let networker = NetworkManager.shared

    init(user: String = Constants.user) {
        self.user = user
    }

    private var animeState: ListState<MALListAnime> {
        get { animeLists[animeStatus] ?? ListState() }
    }

    private var mangaState: ListState<MALListManga> {
        get { mangaLists[mangaStatus] ?? ListState() }
    }

    // My list tab needs to filter away items with removed or changed statuses as they are directly modified by edit without refreshing
    private func isVisible(_ item: MALListAnime, in status: StatusEnum) -> Bool {
        guard user == Constants.user else {
            return true
        }
        guard let current = networker.getAnimeListStatus(item.id).value?.status else {
            return false
        }
        return status == .none || current == status
    }

    private func isVisible(_ item: MALListManga, in status: StatusEnum) -> Bool {
        guard user == Constants.user else {
            return true
        }
        guard let current = networker.getMangaListStatus(item.id).value?.status else {
            return false
        }
        return status == .none || current == status
    }

    // Items for the currently selected status
    var animeItems: [MALListAnime] {
        (animeLists[animeStatus]?.items ?? []).filter { isVisible($0, in: animeStatus) }
    }
    var mangaItems: [MALListManga] {
        (mangaLists[mangaStatus]?.items ?? []).filter { isVisible($0, in: mangaStatus) }
    }

    // Check if the current anime/manga list is loading
    func isLoading() -> Bool {
        return loadingState == .loading || loadingState == .paginating || isRefreshLoading
    }

    // Check if the current anime/manga list is empty
    func isItemsEmpty() -> Bool {
        return (type == .anime && animeItems.isEmpty) || (type == .manga && mangaItems.isEmpty)
    }

    // Get canLoadMorePages variable for the current anime/manga list
    func getCanLoadMorePages() -> Bool {
        return (type == .anime && animeState.canLoadMore) || (type == .manga && mangaState.canLoadMore)
    }

    func updateAnime(id: Int, listStatus: MyListStatus) async {
        isRefreshLoading = true
        do {
            // Writes into the global list status store, views update from there
            try await networker.editUserAnime(id: id, listStatus: listStatus)
        } catch {
            isEditError = true
        }
        isRefreshLoading = false
    }

    func updateManga(id: Int, listStatus: MyListStatus) async {
        isRefreshLoading = true
        do {
            try await networker.editUserManga(id: id, listStatus: listStatus)
        } catch {
            isEditError = true
        }
        isRefreshLoading = false
    }

    // Refresh anime list
    private func refreshAnime(_ clear: Bool = false) async {
        defer {
            isRefreshLoading = false
        }

        let status = animeStatus
        isUserNotFound = false
        isAnimePrivate = false
        if clear {
            loadingState = .loading
            animeLists = [:]
        } else if animeLists[status]?.items.isEmpty ?? true {
            loadingState = .loading
        } else {
            isRefreshLoading = true
        }
        do {
            let animeList = try await networker.getUserAnimeList(user: user, page: 1, status: status, sort: animeSort)
            animeLists[status] = ListState(items: animeList, page: 2, canLoadMore: animeList.count > 20)
            loadingState = .idle
        } catch {
            // If 403 unauthorized and not current user, it means they have privated their list
            if case NetworkError.badStatusCode(403) = error, user != Constants.user {
                isAnimePrivate = true
                animeLists[status, default: ListState()].canLoadMore = false
                loadingState = .idle
            } else if case NetworkError.notFound = error {
                isUserNotFound = true
                loadingState = .idle
            } else {
                loadingState = .error
            }
        }
    }

    // Refresh manga list
    private func refreshManga(_ clear: Bool = false) async {
        defer {
            isRefreshLoading = false
        }

        let status = mangaStatus
        isUserNotFound = false
        isMangaPrivate = false
        if clear {
            loadingState = .loading
            mangaLists = [:]
        } else if mangaLists[status]?.items.isEmpty ?? true {
            loadingState = .loading
        } else {
            isRefreshLoading = true
        }
        do {
            let mangaList = try await networker.getUserMangaList(user: user, page: 1, status: status, sort: mangaSort)
            mangaLists[status] = ListState(items: mangaList, page: 2, canLoadMore: mangaList.count > 20)
            loadingState = .idle
        } catch {
            // If 403 unauthorized and not current user, it means they have privated their list
            if case NetworkError.badStatusCode(403) = error, user != Constants.user {
                isMangaPrivate = true
                mangaLists[status, default: ListState()].canLoadMore = false
                loadingState = .idle
            } else if case NetworkError.notFound = error {
                isUserNotFound = true
                loadingState = .idle
            } else {
                loadingState = .error
            }
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
        // only load more when it is not loading, page is not empty, there are more pages to be loaded and page is not refreshing
        let status = animeStatus
        guard let state = animeLists[status], loadingState == .idle && !state.items.isEmpty && state.canLoadMore && !isRefreshLoading else {
            return
        }

        loadingState = .paginating
        if let animeList = try? await networker.getUserAnimeList(user: user, page: state.page, status: status, sort: animeSort) {
            animeLists[status]?.items.append(contentsOf: animeList)
            animeLists[status]?.page += 1
            animeLists[status]?.canLoadMore = animeList.count > 20
        }
        loadingState = .idle
    }

    // Load more of the current manga list
    private func loadMoreManga() async {
        let status = mangaStatus
        guard let state = mangaLists[status], loadingState == .idle && !state.items.isEmpty && state.canLoadMore && !isRefreshLoading else {
            return
        }

        loadingState = .paginating
        if let mangaList = try? await networker.getUserMangaList(user: user, page: state.page, status: status, sort: mangaSort) {
            mangaLists[status]?.items.append(contentsOf: mangaList)
            mangaLists[status]?.page += 1
            mangaLists[status]?.canLoadMore = mangaList.count > 20
        }
        loadingState = .idle
    }

    // Load more anime/manga when reaching the 5th last anime/manga in list
    func loadMoreIfNeeded(index: Int) async {
        if type == .anime {
            if index == animeItems.endIndex - 5 {
                await loadMoreAnime()
            }
        } else if type == .manga {
            if index == mangaItems.endIndex - 5 {
                await loadMoreManga()
            }
        }
    }
}

struct ListState<Item> {
    var items: [Item] = []
    var page = 1
    var canLoadMore = true
}

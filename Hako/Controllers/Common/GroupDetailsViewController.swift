//
//  GroupDetailsViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import Foundation

@MainActor
class GroupDetailsViewController: ObservableObject {
    @Published var items: [JikanListItem] = []
    @Published var loadingState: LoadingEnum = .loading
    private var currentPage = 1
    private var canLoadMorePages = true
    private let group: String
    private let id: Int
    private let type: TypeEnum
    let networker = NetworkManager.shared
    
    init(group: String, id: Int, type: TypeEnum) {
        self.group = group
        self.id = id
        self.type = type
        Task {
            await refresh()
        }
    }
    
    // Refresh the current anime/manga list
    func refresh() async {
        loadingState = .loading
        currentPage = 1
        canLoadMorePages = true
        do {
            var itemsList: [JikanListItem] = []
            if type == .anime {
                itemsList = try await networker.getAnimeList(group: group, id: id, page: currentPage)
            } else if type == .manga {
                itemsList = try await networker.getMangaList(group: group, id: id, page: currentPage)
            }
            currentPage = 2
            canLoadMorePages = !itemsList.isEmpty
            items = itemsList
            loadingState = .idle
        } catch {
            loadingState = .error
        }
    }
    
    // Load more of the current anime/manga list
    func loadMore() async {
        // only load more when it is not loading, page is not empty and there are more pages to be loaded
        guard loadingState == .idle && !items.isEmpty && canLoadMorePages else {
            return
        }
        
        loadingState = .paginating
        do {
            var itemsList: [JikanListItem] = []
            if type == .anime {
                itemsList = try await networker.getAnimeList(group: group, id: id, page: currentPage)
            } else if type == .manga {
                itemsList = try await networker.getMangaList(group: group, id: id, page: currentPage)
            }
            currentPage += 1
            canLoadMorePages = !itemsList.isEmpty
            items.append(contentsOf: itemsList)
        } catch {}
        loadingState = .idle
    }
    
    // Load more items when reaching the 4th last items in list
    func loadMoreIfNeeded(index: Int) async {
        if index == items.endIndex - 5 {
            return await loadMore()
        }
    }
}

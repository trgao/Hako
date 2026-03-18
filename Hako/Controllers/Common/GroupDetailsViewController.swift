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
    private var ids: Set<Int> = []
    private let urlExtend: String
    private let type: TypeEnum
    let networker = NetworkManager.shared
    
    init(group: String, id: Int, type: TypeEnum) {
        self.urlExtend = "\(group)=\(id)&order_by=popularity"
        self.type = type
        Task {
            await refresh()
        }
    }
    
    func isLoading() -> Bool {
        return loadingState == .loading || loadingState == .paginating
    }
    
    // Refresh the current anime/manga list
    func refresh() async {
        loadingState = .loading
        currentPage = 1
        canLoadMorePages = true
        ids = []
        do {
            var itemsList: [JikanListItem] = []
            var results: [JikanListItem] = []
            if type == .anime {
                itemsList = try await networker.getAnimeList(urlExtend: urlExtend, page: currentPage)
            } else if type == .manga {
                itemsList = try await networker.getMangaList(urlExtend: urlExtend, page: currentPage)
            }
            currentPage = 2
            canLoadMorePages = !itemsList.isEmpty
            for item in itemsList {
                if !ids.contains(item.id) {
                    ids.insert(item.id)
                    results.append(item)
                }
            }
            items = results
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
            var results: [JikanListItem] = []
            if type == .anime {
                itemsList = try await networker.getAnimeList(urlExtend: urlExtend, page: currentPage)
            } else if type == .manga {
                itemsList = try await networker.getMangaList(urlExtend: urlExtend, page: currentPage)
            }
            currentPage += 1
            canLoadMorePages = !itemsList.isEmpty
            for item in itemsList {
                if !ids.contains(item.id) {
                    ids.insert(item.id)
                    results.append(item)
                }
            }
            items.append(contentsOf: results)
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

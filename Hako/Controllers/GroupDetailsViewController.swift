//
//  GroupDetailsViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import Foundation

@MainActor
class GroupDetailsViewController: ObservableObject {
    @Published var items = [JikanListItem]()
    @Published var isLoading = false
    @Published var isLoadingError = false
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
    
    // Refresh the current anime/manga list
    func refresh() async {
        currentPage = 1
        canLoadMorePages = true
        ids = []
        isLoading = true
        isLoadingError = false
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
        } catch {
            isLoadingError = true
        }
        isLoading = false
    }
    
    // Load more of the current anime/manga list
    private func loadMore() async {
        // only load more when it is not loading and there are more pages to be loaded
        guard !isLoading && canLoadMorePages else {
            return
        }
        
        // only load more when there are already items on the page
        guard items.count > 0 else {
            return
        }
        
        isLoading = true
        isLoadingError = false
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
        } catch {
            isLoadingError = true
        }
        isLoading = false
    }
    
    // Load more items when reaching the 4th last items in list
    func loadMoreIfNeeded(index: Int) async {
        let thresholdIndex = items.index(items.endIndex, offsetBy: -4)
        if index == thresholdIndex {
            return await loadMore()
        }
    }
}

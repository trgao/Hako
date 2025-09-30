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
    
    init(urlExtend: String, type: TypeEnum) {
        self.urlExtend = urlExtend
        self.type = type
        Task {
            await refresh()
        }
    }
    
    // Refresh the current anime/manga list
    func refresh() async {
        currentPage = 1
        canLoadMorePages = true
        isLoading = true
        isLoadingError = false
        do {
            if type == .anime {
                let animeList = try await networker.getAnimeList(urlExtend: urlExtend, page: currentPage)
                currentPage = 2
                canLoadMorePages = !(animeList.isEmpty)
                for item in animeList {
                    if !ids.contains(item.id) {
                        ids.insert(item.id)
                        items.append(item)
                    }
                }
            } else if type == .manga {
                let mangaList = try await networker.getMangaList(urlExtend: urlExtend, page: currentPage)
                currentPage = 2
                canLoadMorePages = !(mangaList.isEmpty)
                for item in mangaList {
                    if !ids.contains(item.id) {
                        ids.insert(item.id)
                        items.append(item)
                    }
                }
            }
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
            if type == .anime {
                let animeList = try await networker.getAnimeList(urlExtend: urlExtend, page: currentPage)
                currentPage += 1
                canLoadMorePages = !(animeList.isEmpty)
                for item in animeList {
                    if !ids.contains(item.id) {
                        ids.insert(item.id)
                        items.append(item)
                    }
                }
            } else if type == .manga {
                let mangaList = try await networker.getMangaList(urlExtend: urlExtend, page: currentPage)
                currentPage += 1
                canLoadMorePages = !(mangaList.isEmpty)
                for item in mangaList {
                    if !ids.contains(item.id) {
                        ids.insert(item.id)
                        items.append(item)
                    }
                }
            }
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

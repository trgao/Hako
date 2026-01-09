//
//  StudiosListViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 7/1/26.
//

import Foundation

@MainActor
class StudiosListViewController: ObservableObject {
    @Published var studios: [JikanListItem] = []
    @Published var isLoading = true
    @Published var isLoadingError = false
    private var ids: Set<Int> = []
    private var currentPage = 1
    private var canLoadMorePages = true
    private let networker = NetworkManager.shared
    
    // Refresh the studios list page
    func refresh() async {
        isLoading = true
        isLoadingError = false
        ids = []
        currentPage = 1
        canLoadMorePages = true
        do {
            let studioList = try await networker.getStudios(page: currentPage)
            var results: [JikanListItem] = []
            currentPage = 2
            canLoadMorePages = !studioList.isEmpty
            for item in studioList {
                if !ids.contains(item.id) {
                    ids.insert(item.id)
                    results.append(item)
                }
            }
            studios = results
        } catch {
            isLoadingError = true
        }
        isLoading = false
    }
    
    // Load more of the current studios list
    func loadMore() async {
        isLoading = true
        isLoadingError = false
        do {
            let studioList = try await networker.getStudios(page: currentPage)
            var results: [JikanListItem] = []
            currentPage += 1
            canLoadMorePages = !studioList.isEmpty
            for item in studioList {
                if !ids.contains(item.id) {
                    ids.insert(item.id)
                    results.append(item)
                }
            }
            studios.append(contentsOf: results)
        } catch {
            isLoadingError = true
        }
        isLoading = false
    }
    
    // Load more studios when reaching the 4th last studio in list
    func loadMoreIfNeeded(index: Int) async {
        if index == studios.index(studios.endIndex, offsetBy: -4) {
            return await loadMore()
        }
    }
}

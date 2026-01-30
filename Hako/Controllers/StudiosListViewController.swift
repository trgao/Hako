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
    @Published var loadingState: LoadingEnum = .loading
    private var ids: Set<Int> = []
    private var currentPage = 1
    private var canLoadMorePages = true
    private let networker = NetworkManager.shared
    
    // Refresh the studios list page
    func refresh() async {
        loadingState = .loading
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
            loadingState = .idle
        } catch {
            loadingState = .error
        }
    }
    
    // Load more of the current studios list
    func loadMore() async {
        // only load more when it is not loading, page is not empty and there are more pages to be loaded
        guard loadingState == .idle && !studios.isEmpty && canLoadMorePages else {
            return
        }
        
        loadingState = .paginating
        if let studioList = try? await networker.getStudios(page: currentPage) {
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
        }
        loadingState = .idle
    }
}

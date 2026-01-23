//
//  MagazinesListViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 7/1/26.
//

import Foundation

@MainActor
class MagazinesListViewController: ObservableObject {
    @Published var magazines: [JikanListItem] = []
    @Published var isLoading = true
    @Published var isLoadingError = false
    private var ids: Set<Int> = []
    private var currentPage = 1
    private var canLoadMorePages = true
    private let networker = NetworkManager.shared
    
    // Refresh the magazines list page
    func refresh() async {
        isLoading = true
        isLoadingError = false
        ids = []
        currentPage = 1
        canLoadMorePages = true
        do {
            let magazineList = try await networker.getMagazines(page: currentPage)
            var results: [JikanListItem] = []
            currentPage = 2
            canLoadMorePages = !magazineList.isEmpty
            for item in magazineList {
                if !ids.contains(item.id) {
                    ids.insert(item.id)
                    results.append(item)
                }
            }
            magazines = results
        } catch {
            isLoadingError = true
        }
        isLoading = false
    }
    
    // Load more of the current magazines list
    func loadMore() async {
        // only load more when it is not loading, page is not empty and there are more pages to be loaded
        guard !isLoading && !magazines.isEmpty && canLoadMorePages else {
            return
        }
        
        isLoading = true
        isLoadingError = false
        do {
            let magazineList = try await networker.getMagazines(page: currentPage)
            var results: [JikanListItem] = []
            currentPage += 1
            canLoadMorePages = !magazineList.isEmpty
            for item in magazineList {
                if !ids.contains(item.id) {
                    ids.insert(item.id)
                    results.append(item)
                }
            }
            magazines.append(contentsOf: results)
        } catch {
            isLoadingError = true
        }
        isLoading = false
    }
}

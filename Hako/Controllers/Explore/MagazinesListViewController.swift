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
    @Published var loadingState: LoadingEnum = .loading
    private var ids: Set<Int> = []
    private var currentPage = 1
    private var canLoadMorePages = true
    private let networker = NetworkManager.shared
    
    // Refresh the magazines list page
    func refresh() async {
        loadingState = .loading
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
            loadingState = .idle
        } catch {
            loadingState = .error
        }
    }
    
    // Load more of the current magazines list
    func loadMore() async {
        // only load more when it is not loading, page is not empty and there are more pages to be loaded
        guard loadingState == .idle && !magazines.isEmpty && canLoadMorePages else {
            return
        }
        
        loadingState = .paginating
        if let magazineList = try? await networker.getMagazines(page: currentPage) {
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
        }
        loadingState = .idle
    }
}

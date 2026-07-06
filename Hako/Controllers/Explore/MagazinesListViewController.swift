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
    private var currentPage = 1
    private var canLoadMorePages = true
    private let networker = NetworkManager.shared
    
    // Refresh the magazines list page
    func refresh() async {
        loadingState = .loading
        currentPage = 1
        canLoadMorePages = true
        do {
            let magazineList = try await networker.getMagazines(page: currentPage)
            currentPage = 2
            canLoadMorePages = !magazineList.isEmpty
            magazines = magazineList
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
            currentPage += 1
            canLoadMorePages = !magazineList.isEmpty
            magazines.append(contentsOf: magazineList)
        }
        loadingState = .idle
    }
}

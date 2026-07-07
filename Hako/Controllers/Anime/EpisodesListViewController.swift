//
//  EpisodesListViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 7/7/26.
//

import Foundation

@MainActor
class EpisodesListViewController: ObservableObject {
    @Published var episodes: [Episode] = []
    @Published var loadingState: LoadingEnum = .loading
    private var currentPage = 1
    private var canLoadMorePages = true
    private let id: Int
    private let networker = NetworkManager.shared
    
    init(id: Int) {
        self.id = id
    }
    
    // Refresh the current episodes list
    func refresh() async {
        loadingState = .loading
        currentPage = 1
        canLoadMorePages = false
        do {
            let episodesList = try await networker.getAnimeEpisodesList(id: id, page: currentPage)
            currentPage = 2
            canLoadMorePages = !episodesList.isEmpty
            episodes = episodesList
            loadingState = .idle
        } catch {
            loadingState = .error
        }
    }
    
    // Load more of the current episodes list
    func loadMore() async {
        // only load more when it is not loading, page is not empty and there are more pages to be loaded
        guard loadingState == .idle && !episodes.isEmpty && canLoadMorePages else {
            return
        }
        
        loadingState = .paginating
        if let episodesList = try? await networker.getAnimeEpisodesList(id: id, page: currentPage) {
            currentPage += 1
            canLoadMorePages = !episodesList.isEmpty
            episodes.append(contentsOf: episodesList)
        }
        loadingState = .idle
    }
    
    // Load more episodes when reaching the 3rd last episode in list
    func loadMoreIfNeeded(index: Int) async {
        if index == episodes.endIndex - 5 {
            return await loadMore()
        }
    }
}

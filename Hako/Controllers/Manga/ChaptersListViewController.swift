//
//  ChaptersListViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 15/10/26.
//

import Foundation

@MainActor
class ChaptersListViewController: ObservableObject {
    @Published var chapters: [Chapter] = []
    @Published var loadingState: LoadingEnum = .loading
    private var currentPage = 1
    private var canLoadMorePages = true
    private let id: Int
    private let networker = NetworkManager.shared
    
    init(id: Int) {
        self.id = id
    }
    
    // Refresh the current chapters list
    func refresh() async {
        loadingState = .loading
        currentPage = 1
        canLoadMorePages = false
        do {
            let chaptersList = try await networker.getMangaChaptersList(id: id, page: currentPage)
            currentPage = 2
            canLoadMorePages = !chaptersList.isEmpty
            chapters = chaptersList
            loadingState = .idle
        } catch {
            loadingState = .error
        }
    }
    
    // Load more of the current chapters list
    func loadMore() async {
        // only load more when it is not loading, page is not empty and there are more pages to be loaded
        guard loadingState == .idle && !chapters.isEmpty && canLoadMorePages else {
            return
        }
        
        loadingState = .paginating
        if let chaptersList = try? await networker.getMangaChaptersList(id: id, page: currentPage) {
            currentPage += 1
            canLoadMorePages = !chaptersList.isEmpty
            chapters.append(contentsOf: chaptersList)
        }
        loadingState = .idle
    }
    
    // Load more chapters when reaching the 3rd last chapter in list
    func loadMoreIfNeeded(index: Int) async {
        if index == chapters.endIndex - 5 {
            return await loadMore()
        }
    }
}

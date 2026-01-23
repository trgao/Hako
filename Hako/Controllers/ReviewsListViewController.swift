//
//  ReviewsListViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 14/6/25.
//

import Foundation

@MainActor
class ReviewsListViewController: ObservableObject {
    @Published var reviews = [Review]()
    @Published var isLoading = false
    @Published var currentPage = 1
    @Published var canLoadMorePages = true
    @Published var isLoadingError = false
    private let id: Int
    private let type: TypeEnum
    private var ids: Set<Int> = []
    let networker = NetworkManager.shared
    
    init(id: Int, type: TypeEnum) {
        self.id = id
        self.type = type
    }
    
    // Refresh the current reviews list
    func refresh() async {
        isLoadingError = false
        currentPage = 1
        ids = []
        canLoadMorePages = false
        isLoading = true
        do {
            var reviewsList: [Review] = []
            var results: [Review] = []
            if type == .anime {
                reviewsList = try await networker.getAnimeReviewsList(id: id, page: currentPage)
            } else if type == .manga {
                reviewsList = try await networker.getMangaReviewsList(id: id, page: currentPage)
            }
            currentPage = 2
            canLoadMorePages = !reviewsList.isEmpty
            for item in reviewsList {
                if !ids.contains(item.id) {
                    ids.insert(item.id)
                    results.append(item)
                }
            }
            reviews = results
        } catch {
            isLoadingError = true
        }
        isLoading = false
    }
    
    // Load more of the current reviews list
    private func loadMore() async {
        // only load more when it is not loading, page is not empty and there are more pages to be loaded
        guard !isLoading && !reviews.isEmpty && canLoadMorePages else {
            return
        }
        
        isLoading = true
        isLoadingError = false
        do {
            var reviewsList: [Review] = []
            var results: [Review] = []
            if type == .anime {
                reviewsList = try await networker.getAnimeReviewsList(id: id, page: currentPage)
            } else if type == .manga {
                reviewsList = try await networker.getMangaReviewsList(id: id, page: currentPage)
            }
            currentPage += 1
            canLoadMorePages = !reviewsList.isEmpty
            for item in reviewsList {
                if !ids.contains(item.id) {
                    ids.insert(item.id)
                    results.append(item)
                }
            }
            reviews.append(contentsOf: results)
        } catch {
            isLoadingError = true
        }
        isLoading = false
    }
    
    // Load more review when reaching the 3rd last review in list
    func loadMoreIfNeeded(index: Int) async {
        if index == reviews.endIndex - 5 {
            return await loadMore()
        }
    }
}

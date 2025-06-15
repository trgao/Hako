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
    @Published var canLoadMore = true
    @Published var isLoadingError = false
    private let id: Int
    private let type: TypeEnum
    let networker = NetworkManager.shared
    
    init(id: Int, type: TypeEnum) {
        self.id = id
        self.type = type
    }
    
    // Check if the current reviews list should be refreshed
    func shouldRefresh() -> Bool {
        return reviews.isEmpty && canLoadMore
    }
    
    // Refresh the current reviews list
    func refresh() async -> Void {
        isLoadingError = false
        currentPage = 1
        canLoadMore = false
        isLoading = true
        if type == .anime {
            do {
                let reviewsList = try await networker.getAnimeReviewsList(id: id, page: currentPage)
                currentPage = 2
                canLoadMore = !(reviewsList.isEmpty)
                reviews = reviewsList
            } catch {
                isLoadingError = true
            }
        } else if type == .manga {
            do {
                let reviewsList = try await networker.getMangaReviewsList(id: id, page: currentPage)
                currentPage = 2
                canLoadMore = !(reviewsList.isEmpty)
                reviews = reviewsList
            } catch {
                isLoadingError = true
            }
        }
        isLoading = false
    }
    
    // Load more of the current reviews list
    private func loadMore() async -> Void {
        // only load more when it is not loading and there are more pages to be loaded
        guard !isLoading && canLoadMore else {
            return
        }
        
        // only load more when there are already items on the page
        guard reviews.count > 0 else {
            return
        }
        
        isLoading = true
        isLoadingError = false
        if type == .anime {
            do {
                let reviewsList = try await networker.getAnimeReviewsList(id: id, page: currentPage)
                currentPage += 1
                canLoadMore = !(reviewsList.isEmpty)
                reviews.append(contentsOf: reviewsList)
            } catch {
                print(error)
                isLoadingError = true
            }
        } else if type == .manga {
            do {
                let reviewsList = try await networker.getMangaReviewsList(id: id, page: currentPage)
                currentPage = 2
                canLoadMore = !(reviewsList.isEmpty)
                reviews.append(contentsOf: reviewsList)
            } catch {
                isLoadingError = true
            }
        }
        isLoading = false
    }
    
    // Load more review when reaching the 4th last review in list
    func loadMoreIfNeeded(index: Int) async -> Void {
        let thresholdIndex = reviews.index(reviews.endIndex, offsetBy: -4)
        if index == thresholdIndex {
            return await loadMore()
        }
    }
}

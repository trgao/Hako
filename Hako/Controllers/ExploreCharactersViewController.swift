//
//  ExploreCharactersViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 7/1/26.
//

import Foundation

@MainActor
class ExploreCharactersViewController: ObservableObject {
    @Published var characters: [JikanListItem] = []
    @Published var isLoading = true
    @Published var isLoadingError = false
    private var ids: Set<Int> = []
    private var currentPage = 1
    private var canLoadMorePages = true
    private let networker = NetworkManager.shared
    
    // Refresh the characters list page
    func refresh() async {
        isLoading = true
        isLoadingError = false
        ids = []
        currentPage = 1
        canLoadMorePages = true
        do {
            let characterList = try await networker.getCharacters(page: currentPage)
            var results: [JikanListItem] = []
            currentPage = 2
            canLoadMorePages = !characterList.isEmpty
            for item in characterList {
                if !ids.contains(item.id) {
                    ids.insert(item.id)
                    results.append(item)
                }
            }
            characters = results
        } catch {
            isLoadingError = true
        }
        isLoading = false
    }
    
    // Load more of the current characters list
    private func loadMore() async {
        // only load more when it is not loading, page is not empty and there are more pages to be loaded
        guard !isLoading && !characters.isEmpty && canLoadMorePages else {
            return
        }
        
        isLoading = true
        isLoadingError = false
        do {
            let characterList = try await networker.getCharacters(page: currentPage)
            var results: [JikanListItem] = []
            currentPage += 1
            canLoadMorePages = !characterList.isEmpty
            for item in characterList {
                if !ids.contains(item.id) {
                    ids.insert(item.id)
                    results.append(item)
                }
            }
            characters.append(contentsOf: results)
        } catch {
            isLoadingError = true
        }
        isLoading = false
    }
    
    // Load more characters when reaching the 4th last character in list
    func loadMoreIfNeeded(index: Int) async {
        if index == characters.endIndex - 5 {
            return await loadMore()
        }
    }
}

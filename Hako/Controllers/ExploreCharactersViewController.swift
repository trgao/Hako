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
    @Published var loadId = UUID()
    private var currentPage = 1
    private var canLoadMorePages = true
    private let networker = NetworkManager.shared
    
    // Refresh the characters list page
    func refresh() async {
        loadId = UUID()
        isLoading = true
        isLoadingError = false
        currentPage = 1
        canLoadMorePages = true
        do {
            let characters = try await networker.getCharacters(page: currentPage)
            currentPage = 2
            canLoadMorePages = characters.count > 0
            self.characters = characters
        } catch {
            isLoadingError = true
        }
        isLoading = false
    }
    
    // Load more of the current characters list
    func loadMore() async {
        isLoading = true
        isLoadingError = false
        do {
            let characters = try await networker.getCharacters(page: currentPage)
            currentPage += 1
            canLoadMorePages = characters.count > 0
            self.characters.append(contentsOf: characters)
        } catch {
            isLoadingError = true
        }
        isLoading = false
    }
    
    // Load more characters when reaching the 4th last character in list
    func loadMoreIfNeeded(index: Int) async {
        if index == characters.index(characters.endIndex, offsetBy: -4) {
            return await loadMore()
        }
    }
}

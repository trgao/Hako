//
//  ExplorePeopleViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 7/1/26.
//

import Foundation

@MainActor
class ExplorePeopleViewController: ObservableObject {
    @Published var people: [JikanListItem] = []
    @Published var isLoading = true
    @Published var isLoadingError = false
    @Published var loadId = UUID()
    private var currentPage = 1
    private var canLoadMorePages = true
    private let networker = NetworkManager.shared
    
    // Refresh the people list page
    func refresh() async {
        loadId = UUID()
        isLoading = true
        isLoadingError = false
        do {
            self.people = try await networker.getPeople(page: currentPage)
        } catch {
            isLoadingError = true
        }
        isLoading = false
    }
    
    // Load more of the current people list
    func loadMore() async {
        isLoading = true
        isLoadingError = false
        do {
            let people = try await networker.getPeople(page: currentPage)
            currentPage += 1
            canLoadMorePages = people.count > 0
            self.people.append(contentsOf: people)
        } catch {
            isLoadingError = true
        }
        isLoading = false
    }
    
    // Load more people when reaching the 4th last character in list
    func loadMoreIfNeeded(index: Int) async {
        if index == people.index(people.endIndex, offsetBy: -4) {
            return await loadMore()
        }
    }
}

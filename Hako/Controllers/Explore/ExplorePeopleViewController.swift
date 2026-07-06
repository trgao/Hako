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
    @Published var loadingState: LoadingEnum = .loading
    private var currentPage = 1
    private var canLoadMorePages = true
    private let networker = NetworkManager.shared
    
    // Refresh the people list page
    func refresh() async {
        loadingState = .loading
        currentPage = 1
        canLoadMorePages = true
        do {
            let peopleList = try await networker.getPeople(page: currentPage)
            currentPage = 2
            canLoadMorePages = !peopleList.isEmpty
            people = peopleList
            loadingState = .idle
        } catch {
            loadingState = .error
        }
    }
    
    // Load more of the current people list
    private func loadMore() async {
        // only load more when it is not loading, page is not empty and there are more pages to be loaded
        guard loadingState == .idle && !people.isEmpty && canLoadMorePages else {
            return
        }
        
        loadingState = .paginating
        if let peopleList = try? await networker.getPeople(page: currentPage) {
            currentPage += 1
            canLoadMorePages = !peopleList.isEmpty
            people.append(contentsOf: peopleList)
        }
        loadingState = .idle
    }
    
    // Load more people when reaching the 4th last person in list
    func loadMoreIfNeeded(index: Int) async {
        if index == people.endIndex - 5 {
            return await loadMore()
        }
    }
}

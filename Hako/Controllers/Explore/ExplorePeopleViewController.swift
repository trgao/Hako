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
    private var ids: Set<Int> = []
    private var currentPage = 1
    private var canLoadMorePages = true
    private let networker = NetworkManager.shared
    
    // Refresh the people list page
    func refresh() async {
        loadingState = .loading
        ids = []
        currentPage = 1
        canLoadMorePages = true
        do {
            let peopleList = try await networker.getPeople(page: currentPage)
            var results: [JikanListItem] = []
            currentPage = 2
            canLoadMorePages = !peopleList.isEmpty
            for item in peopleList {
                if !ids.contains(item.id) {
                    ids.insert(item.id)
                    results.append(item)
                }
            }
            people = results
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
            var results: [JikanListItem] = []
            currentPage += 1
            canLoadMorePages = !peopleList.isEmpty
            for item in peopleList {
                if !ids.contains(item.id) {
                    ids.insert(item.id)
                    results.append(item)
                }
            }
            people.append(contentsOf: results)
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

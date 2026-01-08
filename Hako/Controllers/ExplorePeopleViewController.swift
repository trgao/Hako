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
    private var ids: Set<Int> = []
    private var currentPage = 1
    private var canLoadMorePages = true
    private let networker = NetworkManager.shared
    
    // Refresh the people list page
    func refresh() async {
        isLoading = true
        isLoadingError = false
        currentPage = 1
        canLoadMorePages = true
        do {
            let peopleList = try await networker.getPeople(page: currentPage)
            currentPage = 2
            canLoadMorePages = peopleList.count > 0
            for item in peopleList {
                if !ids.contains(item.id) {
                    ids.insert(item.id)
                    people.append(item)
                }
            }
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
            let peopleList = try await networker.getPeople(page: currentPage)
            currentPage += 1
            canLoadMorePages = peopleList.count > 0
            for item in peopleList {
                if !ids.contains(item.id) {
                    ids.insert(item.id)
                    people.append(item)
                }
            }
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

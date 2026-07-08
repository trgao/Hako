//
//  CompaniesListViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 7/1/26.
//

import Foundation

@MainActor
class CompaniesListViewController: ObservableObject {
    @Published var companies: [JikanListItem] = []
    @Published var loadingState: LoadingEnum = .loading
    private var currentPage = 1
    private var canLoadMorePages = true
    private let networker = NetworkManager.shared
    
    // Refresh the companies list page
    func refresh() async {
        loadingState = .loading
        currentPage = 1
        canLoadMorePages = true
        do {
            let companyList = try await networker.getCompanies(page: currentPage)
            currentPage = 2
            canLoadMorePages = !companyList.isEmpty
            companies = companyList
            loadingState = .idle
        } catch {
            loadingState = .error
        }
    }
    
    // Load more of the current companies list
    func loadMore() async {
        // only load more when it is not loading, page is not empty and there are more pages to be loaded
        guard loadingState == .idle && !companies.isEmpty && canLoadMorePages else {
            return
        }
        
        loadingState = .paginating
        if let companyList = try? await networker.getCompanies(page: currentPage) {
            currentPage += 1
            canLoadMorePages = !companyList.isEmpty
            companies.append(contentsOf: companyList)
        }
        loadingState = .idle
    }
}

//
//  NewsListViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 1/12/25.
//

import Foundation
import FeedKit

@MainActor
class NewsListViewController: ObservableObject {
    @Published var news: [RSSFeedItem] = []
    @Published var isLoading = true
    @Published var isLoadingError = false
    let networker = NetworkManager.shared
    
    init() {
        Task {
            await refresh()
        }
    }
    
    // Refresh the news list page
    func refresh() async {
        isLoading = true
        isLoadingError = false
        do {
            let news = try await networker.getNews() ?? []
            self.news = news
        } catch {
            isLoadingError = true
        }
        isLoading = false
    }
}

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
    @Published var loadId = UUID()
    private let networker = NetworkManager.shared
    
    // Refresh the news list page
    func refresh() async {
        loadId = UUID()
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

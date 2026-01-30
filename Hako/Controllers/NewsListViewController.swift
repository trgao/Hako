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
    @Published var loadingState: LoadingEnum = .loading
    private let networker = NetworkManager.shared
    
    // Refresh the news list page
    func refresh() async {
        loadingState = .loading
        do {
            let news = try await networker.getNews() ?? []
            self.news = news
            loadingState = .idle
        } catch {
            loadingState = .error
        }
    }
}

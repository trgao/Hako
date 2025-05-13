//
//  AnimeStatisticsController.swift
//  MALC
//
//  Created by Gao Tianrun on 21/5/24.
//

import Foundation

@MainActor
class AnimeStatisticsController: ObservableObject {
    @Published var statistics: AnimeStats?
    @Published var isLoading = true
    private let id: Int
    let networker = NetworkManager.shared
    
    init(id: Int) {
        self.id = id
        Task {
            do {
                self.statistics = try await self.networker.getAnimeStatistics(id: self.id)
                self.isLoading = false
            } catch {
                print("Some unknown error occurred")
                self.isLoading = false
            }
        }
    }
}

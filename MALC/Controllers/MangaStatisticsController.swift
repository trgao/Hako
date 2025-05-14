//
//  MangaStatisticsController.swift
//  MALC
//
//  Created by Gao Tianrun on 21/5/24.
//

import Foundation

@MainActor
class MangaStatisticsController: ObservableObject {
    @Published var statistics: MangaStats?
    @Published var isLoading = true
    private let id: Int
    let networker = NetworkManager.shared
    
    init(id: Int) {
        self.id = id
        Task {
            do {
                self.statistics = try await networker.getMangaStatistics(id: self.id)
                self.isLoading = false
            } catch {
                print("Some unknown error occurred loading manga statistics")
                print(error)
                self.isLoading = false
            }
        }
    }
}

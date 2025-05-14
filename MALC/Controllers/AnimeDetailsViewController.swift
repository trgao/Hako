//
//  AnimeDetailsViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 29/4/24.
//

import Foundation

@MainActor
class AnimeDetailsViewController: ObservableObject {
    @Published var anime: Anime?
    @Published var characters: [ListCharacter] = []
    @Published var isLoading = false
    @Published var isLoadingError = false
    private let id: Int
    let networker = NetworkManager.shared
    
    init(id: Int) {
        self.id = id
        if let anime = networker.animeCache[id] {
            self.anime = anime
        }
        Task {
            await refresh()
        }
    }
    
    // Refresh the current anime details page
    func refresh() async -> Void {
        isLoading = true
        isLoadingError = false
        do {
            let anime = try await networker.getAnimeDetails(id: id)
            self.anime = anime
            networker.animeCache[id] = anime
            isLoading = false
        } catch {
            isLoadingError = true
            isLoading = false
        }
    }
}

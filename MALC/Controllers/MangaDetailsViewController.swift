//
//  MangaDetailsViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 12/5/24.
//

import Foundation

@MainActor
class MangaDetailsViewController: ObservableObject {
    @Published var manga: Manga?
    @Published var characters: [ListCharacter] = []
    @Published var relations: [Related] = []
    @Published var isLoading = false
    @Published var isLoadingError = false
    private let id: Int
    let networker = NetworkManager.shared
    
    init(id: Int) {
        self.id = id
        if let manga = networker.mangaCache[id] {
            self.manga = manga
        }
        Task {
            await refresh()
        }
    }
    
    // Refresh the current manga details page
    func refresh() async -> Void {
        isLoading = true
        isLoadingError = false
        do {
            let manga = try await networker.getMangaDetails(id: id)
            self.manga = manga
            networker.mangaCache[id] = manga
            isLoading = false
        } catch {
            isLoading = false
            isLoadingError = true
        }
    }
}


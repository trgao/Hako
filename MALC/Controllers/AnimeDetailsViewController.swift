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
    @Published var relations: [Related] = []
    @Published var isInitialLoading = true
    @Published var isLoading = false
    @Published var isLoadingError = false
    private let id: Int
    let networker = NetworkManager.shared
    
    init(id: Int) {
        self.id = id
        
        // Check if anime details is already in cache
        if let animeDetails = networker.animeCache[id] {
            self.anime = animeDetails.anime
            self.characters = animeDetails.characters
            self.relations = animeDetails.relations
            self.isInitialLoading = false
        } else {
            Task {
                do {
                    try await getAnimeDetails()
                    isInitialLoading = false
                } catch {
                    isLoadingError = true
                    isInitialLoading = false
                }
            }
        }
    }
    
    // Load all anime details
    private func getAnimeDetails() async throws -> Void {
        let anime = try await networker.getAnimeDetails(id: id)
        let characterList = try await networker.getAnimeCharacters(id: id)
        let relationList = try await networker.getAnimeRelations(id: id)
        self.anime = anime
        self.characters = characterList
        self.relations = relationList
        networker.animeCache[id] = AnimeDetails(anime: anime, characters: characterList, relations: relationList)
    }
    
    // Refresh the current anime details page
    func refresh() async -> Void {
        isLoading = true
        isLoadingError = false
        do {
            try await getAnimeDetails()
            isLoading = false
        } catch {
            isLoadingError = true
            isLoading = false
        }
    }
}

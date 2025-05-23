//
//  SearchViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 29/5/24.
//

import Foundation

@MainActor
class SearchViewController: ObservableObject {
    // Anime search list variables
    @Published var animeItems = [MALListAnime]()
    @Published var isAnimeSearchLoading = false
    
    // Manga search list variables
    @Published var mangaItems = [MALListManga]()
    @Published var isMangaSearchLoading = false
    
    // Non-search page list variables
    @Published var animeSuggestions = [MALListAnime]()
    @Published var topAiringAnime = [MALListAnime]()
    @Published var topUpcomingAnime = [MALListAnime]()
    @Published var topPopularAnime = [MALListAnime]()
    @Published var topPopularManga = [MALListManga]()
    
    // Common variables
    @Published var isLoadingError = false
    @Published var type: TypeEnum = .anime
    let networker = NetworkManager.shared
    
    func refresh() async -> Void {
        if networker.isSignedIn && self.animeSuggestions.isEmpty {
            let animeSuggestions = try? await networker.getUserAnimeSuggestionList()
            self.animeSuggestions = animeSuggestions ?? []
        }
        if self.topAiringAnime.isEmpty {
            let topAiringAnime = try? await networker.getAnimeTopAiringList()
            self.topAiringAnime = topAiringAnime ?? []
        }
        if self.topUpcomingAnime.isEmpty {
            let topUpcomingAnime = try? await networker.getAnimeTopUpcomingList()
            self.topUpcomingAnime = topUpcomingAnime ?? []
        }
        if self.topPopularAnime.isEmpty {
            let topPopularAnime = try? await networker.getAnimeTopPopularList()
            self.topPopularAnime = topPopularAnime ?? []
        }
        if self.topPopularManga.isEmpty {
            let topPopularManga = try? await networker.getMangaTopPopularList()
            self.topPopularManga = topPopularManga ?? []
        }
    }
    
    // Search for the anime/manga with the title
    func search(_ title: String) async -> Void {
        // Search anime
        isLoadingError = false
        isAnimeSearchLoading = true
        animeItems = []
        do {
            let animeList = try await networker.searchAnime(anime: title)
            animeItems = animeList
        } catch {
            isLoadingError = true
        }
        isAnimeSearchLoading = false
        
        // Search manga
        isLoadingError = false
        isMangaSearchLoading = true
        mangaItems = []
        do {
            let mangaList = try await networker.searchManga(manga: title)
            mangaItems = mangaList
        } catch {
            isLoadingError = true
        }
        isMangaSearchLoading = false
    }
}


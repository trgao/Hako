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
        if networker.isSignedIn {
            let animeSuggestions = try? await networker.getUserAnimeSuggestionList()
            self.animeSuggestions = animeSuggestions ?? []
        }
        let topAiringAnime = try? await networker.getAnimeTopAiringList()
        self.topAiringAnime = topAiringAnime ?? []
        let topUpcomingAnime = try? await networker.getAnimeTopUpcomingList()
        self.topUpcomingAnime = topUpcomingAnime ?? []
        let topPopularAnime = try? await networker.getAnimeTopPopularList()
        self.topPopularAnime = topPopularAnime ?? []
        let topPopularManga = try? await networker.getMangaTopPopularList()
        self.topPopularManga = topPopularManga ?? []
    }
    
    // Check if the lists for the non-search page are empty
    func isPageEmpty() -> Bool {
        return (networker.isSignedIn && animeSuggestions.isEmpty) || topAiringAnime.isEmpty || topUpcomingAnime.isEmpty || topPopularAnime.isEmpty || topPopularManga.isEmpty
    }
    
    // Check if the current anime/manga search list is empty
    func isItemsEmpty() -> Bool {
        return (type == .anime && animeItems.isEmpty) || (type == .manga && mangaItems.isEmpty)
    }
    
    // Search for the anime/manga with the title
    func search(_ title: String) async -> Void {
        animeItems = []
        mangaItems = []
        isLoadingError = false
        if type == .anime {
            do {
                isAnimeSearchLoading = true
                let animeList = try await networker.searchAnime(anime: title)
                animeItems = animeList
                isAnimeSearchLoading = false
            } catch {
                isAnimeSearchLoading = false
                isLoadingError = true
            }
        } else {
            do {
                isMangaSearchLoading = true
                let mangaList = try await networker.searchManga(manga: title)
                mangaItems = mangaList
                isMangaSearchLoading = false
            } catch {
                isMangaSearchLoading = false
                isLoadingError = true
            }
        }
    }
}


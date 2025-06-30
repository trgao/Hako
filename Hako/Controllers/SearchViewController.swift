//
//  SearchViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 29/5/24.
//

import Foundation
import Retry

@MainActor
class SearchViewController: ObservableObject {
    // Anime search list variables
    @Published var animeItems = [MALListAnime]()
    @Published var isAnimeSearchLoading = false
    @Published var isAnimeLoadingError = false
    
    // Manga search list variables
    @Published var mangaItems = [MALListManga]()
    @Published var isMangaSearchLoading = false
    @Published var isMangaLoadingError = false
    
    // Character search list variables
    @Published var characterItems = [JikanListItem]()
    @Published var isCharacterSearchLoading = false
    @Published var isCharacterLoadingError = false
    
    // Person search list variables
    @Published var personItems = [JikanListItem]()
    @Published var isPersonSearchLoading = false
    @Published var isPersonLoadingError = false
    
    // Non-search page list variables
    @Published var animeSuggestions = [MALListAnime]()
    @Published var topAiringAnime = [MALListAnime]()
    @Published var topUpcomingAnime = [MALListAnime]()
    @Published var topPopularAnime = [MALListAnime]()
    @Published var topPopularManga = [MALListManga]()
    
    // Common variables
    @Published var type: SearchEnum = .anime
    let networker = NetworkManager.shared
    
    init() {
        Task {
            if networker.isSignedIn && self.animeSuggestions.isEmpty {
                try? await retry {
                    let animeSuggestions = try? await networker.getUserAnimeSuggestionList()
                    self.animeSuggestions = animeSuggestions ?? []
                }
            }
            if self.topAiringAnime.isEmpty {
                try? await retry {
                    let topAiringAnime = try? await networker.getAnimeTopAiringList()
                    self.topAiringAnime = topAiringAnime ?? []
                }
            }
            if self.topUpcomingAnime.isEmpty {
                try? await retry {
                    let topUpcomingAnime = try? await networker.getAnimeTopUpcomingList()
                    self.topUpcomingAnime = topUpcomingAnime ?? []
                }
            }
            if self.topPopularAnime.isEmpty {
                try? await retry {
                    let topPopularAnime = try? await networker.getAnimeTopPopularList()
                    self.topPopularAnime = topPopularAnime ?? []
                }
            }
            if self.topPopularManga.isEmpty {
                try? await retry {
                    let topPopularManga = try? await networker.getMangaTopPopularList()
                    self.topPopularManga = topPopularManga ?? []
                }
            }
        }
    }
    
    // Search for the anime/manga with the name
    func search(_ name: String) async -> Void {
        Task {
            // Search anime
            isAnimeLoadingError = false
            isAnimeSearchLoading = true
            do {
                let animeList = try await networker.searchAnime(anime: name)
                animeItems = animeList
            } catch {
                isAnimeLoadingError = true
            }
            isAnimeSearchLoading = false
        }
        
        // Search manga
        Task {
            isMangaLoadingError = false
            isMangaSearchLoading = true
            do {
                let mangaList = try await networker.searchManga(manga: name)
                mangaItems = mangaList
            } catch {
                isMangaLoadingError = true
            }
            isMangaSearchLoading = false
        }
        
        // Search character
        Task {
            isCharacterLoadingError = false
            isCharacterSearchLoading = true
            do {
                let characterList = try await networker.searchCharacter(character: name)
                characterItems = characterList
            } catch {
                isCharacterLoadingError = true
            }
            isCharacterSearchLoading = false
        }
        
        // Search person
        Task {
            isPersonLoadingError = false
            isPersonSearchLoading = true
            do {
                let personList = try await networker.searchPerson(person: name)
                personItems = personList
            } catch {
                isPersonLoadingError = true
            }
            isPersonSearchLoading = false
        }
    }
}

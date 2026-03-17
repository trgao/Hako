//
//  ExploreViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 29/5/24.
//

import Foundation
import AsyncAlgorithms

@MainActor
class ExploreViewController: ObservableObject {
    // Anime search list variables
    @Published var animeItems: [MALListAnime] = []
    @Published var isAnimeLoadingError = false
    
    // Manga search list variables
    @Published var mangaItems: [MALListManga] = []
    @Published var isMangaLoadingError = false
    
    // Character search list variables
    @Published var characterItems: [JikanListItem] = []
    @Published var isCharacterLoadingError = false
    
    // Person search list variables
    @Published var personItems: [JikanListItem] = []
    @Published var isPersonLoadingError = false
    
    // Explore page carousel variables
    @Published var animeSuggestions: [MALListAnime] = []
    @Published var topAiringAnime: [MALListAnime] = []
    @Published var topUpcomingAnime: [MALListAnime] = []
    @Published var newlyAddedAnime: [JikanListItem] = []
    @Published var newlyAddedManga: [JikanListItem] = []
    
    @Published var suggestionsLoadingState: LoadingEnum = .loading
    @Published var airingLoadingState: LoadingEnum = .loading
    @Published var upcomingLoadingState: LoadingEnum = .loading
    @Published var newAnimeLoadingState: LoadingEnum = .loading
    @Published var newMangaLoadingState: LoadingEnum = .loading
    
    // Common variables
    @Published var type: SearchEnum = .anime
    @Published var isSearchLoading = false
    @Published var isRefreshLoading = false
    private let networker = NetworkManager.shared
    let queryChannel = AsyncChannel<String>()
    
    func refreshExplore() async {
        suggestionsLoadingState = .loading
        airingLoadingState = .loading
        upcomingLoadingState = .loading
        newAnimeLoadingState = .loading
        newMangaLoadingState = .loading
        
        await loadAnimeSuggestions()
        await loadTopAiringAnime()
        await loadTopUpcomingAnime()
        await loadNewlyAddedAnime()
        await loadNewlyAddedManga()
    }
    
    func loadAnimeSuggestions() async {
        guard networker.isSignedIn && animeSuggestions.isEmpty else {
            suggestionsLoadingState = .idle
            return
        }
        
        suggestionsLoadingState = .loading
        do {
            self.animeSuggestions = try await networker.getUserAnimeSuggestionList()
            suggestionsLoadingState = .idle
        } catch {
            suggestionsLoadingState = .error
        }
    }
    
    func loadTopAiringAnime() async {
        guard topAiringAnime.isEmpty else {
            airingLoadingState = .idle
            return
        }
        
        airingLoadingState = .loading
        do {
            self.topAiringAnime = try await networker.getAnimeTopAiringList()
            airingLoadingState = .idle
        } catch {
            airingLoadingState = .error
        }
    }
    
    func loadTopUpcomingAnime() async {
        guard topUpcomingAnime.isEmpty else {
            upcomingLoadingState = .idle
            return
        }
        
        upcomingLoadingState = .loading
        do {
            self.topUpcomingAnime = try await networker.getAnimeTopUpcomingList()
            upcomingLoadingState = .idle
        } catch {
            upcomingLoadingState = .error
        }
    }
    
    func loadNewlyAddedAnime() async {
        guard newlyAddedAnime.isEmpty else {
            newAnimeLoadingState = .idle
            return
        }
        
        newAnimeLoadingState = .loading
        do {
            var ids: Set<Int> = []
            let newlyAddedAnime = try await networker.getAnimeNewlyAddedList()
            var toAdd: [JikanListItem] = []
            for item in newlyAddedAnime {
                if toAdd.count == 10 {
                    break
                }
                if !ids.contains(item.id) && item.type?.lowercased() != "music" && item.type?.lowercased() != "pv" {
                    ids.insert(item.id)
                    toAdd.append(item)
                }
            }
            self.newlyAddedAnime = toAdd
            newAnimeLoadingState = .idle
        } catch {
            newAnimeLoadingState = .error
        }
    }
    
    func loadNewlyAddedManga() async {
        guard newlyAddedManga.isEmpty else {
            newMangaLoadingState = .idle
            return
        }
        
        newMangaLoadingState = .loading
        do {
            var ids: Set<Int> = []
            let newlyAddedManga = try await networker.getMangaNewlyAddedList()
            var toAdd: [JikanListItem] = []
            for item in newlyAddedManga {
                if toAdd.count == 10 {
                    break
                }
                if !ids.contains(item.id) {
                    ids.insert(item.id)
                    toAdd.append(item)
                }
            }
            self.newlyAddedManga = toAdd
            newMangaLoadingState = .idle
        } catch {
            newMangaLoadingState = .error
        }
    }
    
    // Search for the anime/manga/character/person with query
    func search(query: String) async {
        guard query.count > 2 else {
            animeItems = []
            mangaItems = []
            characterItems = []
            personItems = []
            isSearchLoading = false
            return
        }

        await searchAnime(query: query)
        await searchManga(query: query)
        await searchCharacter(query: query)
        await searchPerson(query: query)
        isSearchLoading = false
    }
    
    func resetSearch() {
        animeItems = []
        mangaItems = []
        characterItems = []
        personItems = []
        isAnimeLoadingError = false
        isMangaLoadingError = false
        isCharacterLoadingError = false
        isPersonLoadingError = false
        
        isSearchLoading = false
        isRefreshLoading = false
    }
    
    func refreshSearch(query: String) async {
        guard query.count > 2 && (!animeItems.isEmpty || !mangaItems.isEmpty) else {
            return
        }
        isRefreshLoading = true
        await searchAnime(query: query)
        await searchManga(query: query)
        isRefreshLoading = false
    }
    
    func searchAnime(query: String) async {
        isAnimeLoadingError = false
        do {
            self.animeItems = try await networker.searchAnime(anime: query).map { item in
                var newItem = item
                newItem.listStatus = item.node.myListStatus
                return newItem
            }
        } catch {
            isAnimeLoadingError = true
        }
    }
    
    func searchManga(query: String) async {
        isMangaLoadingError = false
        do {
            self.mangaItems = try await networker.searchManga(manga: query).map { item in
                var newItem = item
                newItem.listStatus = item.node.myListStatus
                return newItem
            }
        } catch {
            isMangaLoadingError = true
        }
    }
    
    func searchCharacter(query: String) async {
        isCharacterLoadingError = false
        do {
            self.characterItems = try await networker.searchCharacter(character: query)
        } catch {
            isCharacterLoadingError = true
        }
    }
    
    func searchPerson(query: String) async {
        isPersonLoadingError = false
        do {
            self.personItems = try await networker.searchPerson(person: query)
        } catch {
            isPersonLoadingError = true
        }
    }
}

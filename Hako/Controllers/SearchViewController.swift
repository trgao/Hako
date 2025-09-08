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
    @Published var newlyAddedAnime = [JikanListItem]()
    @Published var newlyAddedManga = [JikanListItem]()
    @Published var topPopularAnime = [MALListAnime]()
    @Published var topPopularManga = [MALListManga]()
    
    // Common variables
    @Published var type: SearchEnum = .anime
    let networker = NetworkManager.shared
    
    func refresh() async -> Void {
        if networker.isSignedIn && self.animeSuggestions.isEmpty {
            do {
                self.animeSuggestions = try await networker.getUserAnimeSuggestionList()
            } catch {
                print("Some unknown error occurred loading anime suggestions")
            }
        }
        if self.topAiringAnime.isEmpty {
            do {
                self.topAiringAnime = try await networker.getAnimeTopAiringList()
            } catch {
                print("Some unknown error occurred loading anime top airing")
            }
        }
        if self.topUpcomingAnime.isEmpty {
            do {
                self.topUpcomingAnime = try await networker.getAnimeTopUpcomingList()
            } catch {
                print("Some unknown error occurred loading anime top upcoming")
            }
        }
        if self.newlyAddedAnime.isEmpty {
            do {
                var ids: Set<Int> = []
                let newlyAddedAnime = try await networker.getAnimeNewlyAddedList()
                for item in newlyAddedAnime {
                    if self.newlyAddedAnime.count == 10 {
                        break
                    }
                    if !ids.contains(item.id) {
                        ids.insert(item.id)
                        self.newlyAddedAnime.append(item)
                    }
                }
            } catch {
                print("Some unknown error occurred loading anime newly added")
            }
        }
        if self.newlyAddedManga.isEmpty {
            do {
                var ids: Set<Int> = []
                let newlyAddedManga = try await networker.getMangaNewlyAddedList()
                for item in newlyAddedManga {
                    if self.newlyAddedManga.count == 10 {
                        break
                    }
                    if !ids.contains(item.id) {
                        ids.insert(item.id)
                        self.newlyAddedManga.append(item)
                    }
                }
            } catch {
                print("Some unknown error occurred loading manga newly added")
            }
        }
        if self.topPopularAnime.isEmpty {
            do {
                self.topPopularAnime = try await networker.getAnimeTopPopularList()
            } catch {
                print("Some unknown error occurred loading anime top popular")
            }
        }
        if self.topPopularManga.isEmpty {
            do {
                self.topPopularManga = try await networker.getMangaTopPopularList()
            } catch {
                print("Some unknown error occurred loading manga top popular")
            }
        }
    }
    
    // Search for the anime/manga with the name
    func search(_ name: String) async -> Void {
        Task {
            // Search anime
            isAnimeLoadingError = false
            do {
                self.animeItems = try await networker.searchAnime(anime: name).filter{ $0.node.rating != "rx" }
            } catch {
                isAnimeLoadingError = true
            }
            isAnimeSearchLoading = false
        }
        
        // Search manga
        Task {
            isMangaLoadingError = false
            do {
                self.mangaItems = try await networker.searchManga(manga: name)
            } catch {
                isMangaLoadingError = true
            }
            isMangaSearchLoading = false
        }
        
        // Search character
        Task {
            isCharacterLoadingError = false
            do {
                self.characterItems = try await networker.searchCharacter(character: name)
            } catch {
                isCharacterLoadingError = true
            }
            isCharacterSearchLoading = false
        }
        
        // Search person
        Task {
            isPersonLoadingError = false
            do {
                self.personItems = try await networker.searchPerson(person: name)
            } catch {
                isPersonLoadingError = true
            }
            isPersonSearchLoading = false
        }
    }
}

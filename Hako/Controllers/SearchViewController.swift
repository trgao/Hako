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
    @Published var isAnimeLoadingError = false
    
    // Manga search list variables
    @Published var mangaItems = [MALListManga]()
    @Published var isMangaLoadingError = false
    
    // Character search list variables
    @Published var characterItems = [JikanListItem]()
    @Published var isCharacterLoadingError = false
    
    // Person search list variables
    @Published var personItems = [JikanListItem]()
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
    @Published var isLoading = false
    @Published var isRefreshLoading = false
    @Published var isEditError = false
    let networker = NetworkManager.shared
    
    func resetSearch() -> Void {
        animeItems = []
        mangaItems = []
        characterItems = []
        personItems = []
        isAnimeLoadingError = false
        isMangaLoadingError = false
        isCharacterLoadingError = false
        isPersonLoadingError = false
        
        isLoading = false
        isRefreshLoading = false
    }
    
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
    
    // Search for the anime/manga/character/person with query
    func search(query: String) async -> Void {
        guard query.count > 2 else {
            self.animeItems = []
            self.mangaItems = []
            self.characterItems = []
            self.personItems = []
            self.isLoading = false
            return
        }

        if Task.isCancelled {
            return
        }
        await searchAnime(query: query)

        if Task.isCancelled {
            return
        }
        await searchManga(query: query)

        if Task.isCancelled {
            return
        }
        await searchCharacter(query: query)

        if Task.isCancelled {
            return
        }
        await searchPerson(query: query)

        if Task.isCancelled {
            return
        }
        self.isLoading = false
    }
    
    func refreshSearch(query: String) async -> Void {
        guard query.count > 2 && (!animeItems.isEmpty || !mangaItems.isEmpty) else {
            return
        }
        isRefreshLoading = true
        await searchAnime(query: query)
        await searchManga(query: query)
        isRefreshLoading = false
    }
    
    func searchAnime(query: String) async -> Void {
        isAnimeLoadingError = false
        do {
            self.animeItems = try await networker.searchAnime(anime: query).filter{ $0.node.rating != "rx" }.map { item in
                var newItem = item
                newItem.listStatus = item.node.myListStatus
                return newItem
            }
        } catch {
            isAnimeLoadingError = true
        }
    }
    
    func searchManga(query: String) async -> Void {
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
    
    func searchCharacter(query: String) async -> Void {
        isCharacterLoadingError = false
        do {
            self.characterItems = try await networker.searchCharacter(character: query)
        } catch {
            isCharacterLoadingError = true
        }
    }
    
    func searchPerson(query: String) async -> Void {
        isPersonLoadingError = false
        do {
            self.personItems = try await networker.searchPerson(person: query)
        } catch {
            isPersonLoadingError = true
        }
    }
    
    func updateAnime(index: Int, id: Int, listStatus: MyListStatus) async -> Void {
        isRefreshLoading = true
        do {
            try await networker.editUserAnime(id: id, listStatus: listStatus)
            animeItems[index].listStatus = listStatus
            animeItems[index].node.myListStatus = listStatus
        } catch {
            isEditError = true
        }
        isRefreshLoading = false
    }
    
    func updateManga(index: Int, id: Int, listStatus: MyListStatus) async -> Void {
        isRefreshLoading = true
        do {
            try await networker.editUserManga(id: id, listStatus: listStatus)
            mangaItems[index].listStatus = listStatus
            mangaItems[index].node.myListStatus = listStatus
        } catch {
            isEditError = true
        }
        isRefreshLoading = false
    }
}

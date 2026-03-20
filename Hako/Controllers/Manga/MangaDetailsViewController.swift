//
//  MangaDetailsViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 12/5/24.
//

import SwiftUI

@MainActor
class MangaDetailsViewController: ObservableObject {
    // Data
    @Published var manga: Manga?
    @Published var characters: [ListCharacter]?
    @Published var authors: [Author]?
    @Published var relatedItems: [RelatedItem]?
    @Published var reviews: [Review]?
    
    // Loading states
    @Published var loadingState: LoadingEnum = .loading
    @Published var charactersLoadingState: LoadingEnum = .loading
    @Published var relatedLoadingState: LoadingEnum = .loading
    @Published var reviewsLoadingState: LoadingEnum = .loading
    
    private let id: Int
    private let networker = NetworkManager.shared
    
    init(id: Int) {
        self.id = id
        if let manga = networker.mangaCache[id] {
            self.manga = manga
        }
        Task {
            await loadDetails()
        }
    }
    
    init(manga: Manga) {
        self.id = manga.id
        self.manga = manga
        if let manga = networker.mangaCache[id] {
            self.manga = manga
        }
        Task {
            await loadDetails()
        }
    }
    
    // Refresh the current manga details page
    func refresh() async {
        loadingState = .loading
        charactersLoadingState = .loading
        relatedLoadingState = .loading
        reviewsLoadingState = .loading
        
        await loadDetails()
        await loadCharacters()
        await loadAuthors()
        await loadRelated()
        await loadReviews()
    }
    
    func loadDetails() async {
        loadingState = .loading
        do {
            let manga = try await networker.getMangaDetails(id: id)
            self.manga = manga
            networker.mangaCache[id] = manga
            self.authors = manga.authors
            loadingState = .idle
        } catch {
            if case NetworkError.notFound = error {
                loadingState = .idle
            } else {
                loadingState = .error
            }
        }
    }
    
    func loadCharacters() async {
        if let characters = networker.mangaCharactersCache[id] {
            self.characters = characters
            charactersLoadingState = .idle
            return
        }
        
        charactersLoadingState = .loading
        do {
            let characters = try await networker.getMangaCharacters(id: id)
            self.characters = characters
            networker.mangaCharactersCache[id] = characters
            charactersLoadingState = .idle
        } catch {
            charactersLoadingState = .error
        }
    }
    
    func loadAuthors() async {
        guard let authors = authors else {
            return
        }
        
        await authors.indices.concurrentForEach { i in
            if let person = self.networker.personCache[authors[i].id] {
                self.authors?[i].imageUrl = person.images?.jpg?.imageUrl
            } else {
                let person = try? await self.networker.getPersonDetails(id: authors[i].id)
                self.authors?[i].imageUrl = person?.images?.jpg?.imageUrl
                self.networker.personCache[authors[i].id] = person
            }
        }
    }
    
    func loadRelated() async {
        if let relatedItems = networker.mangaRelatedCache[id] {
            self.relatedItems = relatedItems
            relatedLoadingState = .idle
            return
        }
        
        relatedLoadingState = .loading
        do {
            let relations = try await networker.getMangaRelations(id: id)
            self.relatedItems = relations
                .filter{ $0.relation == "Prequel" || $0.relation == "Sequel" || $0.relation == "Adaptation" || $0.relation == "Parent Story" }
                .flatMap{ category in category.entry.map{ RelatedItem(malId: $0.malId, type: $0.type, title: $0.name, relation: category.relation, anime: nil, manga: nil) } }
            relatedLoadingState = .idle
            if let items = relatedItems {
                var loaded = Array(repeating: true, count: items.count)
                await items.indices.concurrentForEach { i in
                    if items[i].type == .anime {
                        if let anime = self.networker.animeCache[items[i].id] {
                            self.relatedItems?[i].anime = anime
                        } else if let anime = try? await self.networker.getAnimeDetails(id: items[i].id) {
                            self.relatedItems?[i].anime = anime
                            self.networker.animeCache[items[i].id] = anime
                        } else {
                            loaded[i] = false
                        }
                    } else if items[i].type == .manga {
                        if let manga = self.networker.mangaCache[items[i].id] {
                            self.relatedItems?[i].manga = manga
                        } else if let manga = try? await self.networker.getMangaDetails(id: items[i].id) {
                            self.relatedItems?[i].manga = manga
                            self.networker.mangaCache[items[i].id] = manga
                        } else {
                            loaded[i] = false
                        }
                    }
                }
                
                // Only store to cache if all is loaded
                if loaded.reduce(true, { $0 && $1 }) {
                    networker.animeRelatedCache[id] = relatedItems
                }
            }
        } catch {
            relatedLoadingState = .error
        }
    }
    
    func loadReviews() async {
        reviewsLoadingState = .loading
        do {
            let reviews = try await networker.getMangaReviewsList(id: id, page: 1)
            self.reviews = reviews
            reviewsLoadingState = .idle
        } catch {
            reviewsLoadingState = .error
        }
    }
}


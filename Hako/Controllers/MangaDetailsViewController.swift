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
    @Published var authorsLoadingState: LoadingEnum = .loading
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
        charactersLoadingState = .loading
        authorsLoadingState = .loading
        relatedLoadingState = .loading
        reviewsLoadingState = .loading
        await loadDetails()
        
        if Task.isCancelled {
            return
        }
        await loadCharacters()
        
        if Task.isCancelled {
            return
        }
        await loadAuthors()
        
        if Task.isCancelled {
            return
        }
        await loadRelated()
        
        if Task.isCancelled {
            return
        }
        await loadReviews()
    }
    
    func loadDetails() async {
        loadingState = .loading
        do {
            let manga = try await networker.getMangaDetails(id: id)
            self.manga = manga
            networker.mangaCache[id] = manga
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
        charactersLoadingState = .loading
        do {
            if let characters = networker.mangaCharactersCache[id] {
                self.characters = characters
            } else {
                let characters = try await networker.getMangaCharacters(id: id)
                self.characters = characters
                networker.mangaCharactersCache[id] = characters
            }
            charactersLoadingState = .idle
        } catch {
            print("Some unknown error occurred loading manga characters")
            charactersLoadingState = .error
        }
    }
    
    func loadAuthors() async {
        guard loadingState != .loading else {
            return
        }
        guard let manga = manga, loadingState != .error else {
            authorsLoadingState = .error
            return
        }
        authorsLoadingState = .loading
        do {
            if let authors = networker.mangaAuthorsCache[id] {
                self.authors = authors
            } else {
                let mangaAuthors = manga.authors ?? []
                var authors: [Author] = []
                for author in mangaAuthors {
                    var newAuthor = author
                    if let person = networker.personCache[author.id] {
                        newAuthor.imageUrl = person.images?.jpg?.imageUrl
                    } else {
                        let person = try await networker.getPersonDetails(id: author.id)
                        newAuthor.imageUrl = person.images?.jpg?.imageUrl
                    }
                    authors.append(newAuthor)
                }
                self.authors = authors
                networker.mangaAuthorsCache[id] = authors
            }
            authorsLoadingState = .idle
        } catch {
            print("Some unknown error occurred loading manga authors")
            authorsLoadingState = .error
        }
    }
    
    func loadRelated() async {
        relatedLoadingState = .loading
        do {
            if let relatedItems = networker.mangaRelatedCache[id] {
                self.relatedItems = relatedItems
            } else {
                let relations = try await networker.getMangaRelations(id: id)
                var relatedItems = relations.filter{ $0.relation == "Prequel" || $0.relation == "Sequel" || $0.relation == "Adaptation" || $0.relation == "Parent Story" }.flatMap{ category in category.entry.map{ RelatedItem(malId: $0.malId, type: $0.type, title: $0.name, relation: category.relation, anime: nil, manga: nil) } }
                relatedItems = try await relatedItems.concurrentMap { item in
                    var newItem = item
                    if item.type == .anime {
                        if let anime = self.networker.animeCache[item.id] {
                            newItem.anime = anime
                        } else {
                            let anime = try await self.networker.getAnimeDetails(id: item.id)
                            newItem.anime = anime
                        }
                    } else if item.type == .manga {
                        if let manga = self.networker.mangaCache[item.id] {
                            newItem.manga = manga
                        } else {
                            let manga = try await self.networker.getMangaDetails(id: item.id)
                            newItem.manga = manga
                        }
                    }
                    return newItem
                }
                self.relatedItems = relatedItems
                networker.mangaRelatedCache[id] = relatedItems
            }
            relatedLoadingState = .idle
        } catch {
            print("Some unknown error occurred loading manga related items")
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
            print("Some unknown error occurred loading manga reviews")
            reviewsLoadingState = .error
        }
    }
}


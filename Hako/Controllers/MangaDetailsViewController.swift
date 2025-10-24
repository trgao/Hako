//
//  MangaDetailsViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 12/5/24.
//

import Foundation
import SwiftUI

@MainActor
class MangaDetailsViewController: ObservableObject {
    @Published var manga: Manga?
    @Published var characters = [ListCharacter]()
    @Published var authors = [Author]()
    @Published var relatedItems = [RelatedItem]()
    @Published var reviews = [Review]()
    @Published var isLoading = true
    @Published var isLoadingError = false
    private let id: Int
    let networker = NetworkManager.shared
    
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
        Task {
            await loadDetails()
        }
    }
    
    // Refresh the current manga details page
    func refresh() async {
        if Task.isCancelled {
            return
        }
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
        isLoading = true
        isLoadingError = false
        do {
            let manga = try await networker.getMangaDetails(id: id)
            self.manga = manga
            networker.mangaCache[id] = manga
        } catch {
            isLoadingError = true
        }
        isLoading = false
    }
    
    func loadCharacters() async {
        do {
            if let characters = networker.mangaCharactersCache[id] {
                withAnimation {
                    self.characters = characters
                }
            } else {
                let characters = try await networker.getMangaCharacters(id: id)
                withAnimation {
                    self.characters = characters
                }
                networker.mangaCharactersCache[id] = characters
            }
        } catch {
            print("Some unknown error occurred loading manga characters")
        }
    }
    
    func loadAuthors() async {
        do {
            if let authors = networker.mangaAuthorsCache[id] {
                withAnimation {
                    self.authors = authors
                }
            } else {
                let mangaAuthors = manga?.authors ?? []
                var authors: [Author] = []
                for author in mangaAuthors {
                    var newAuthor = author
                    let person = try await self.networker.getPersonDetails(id: author.id)
                    newAuthor.imageUrl = person.images?.jpg?.imageUrl
                    authors.append(newAuthor)
                }
                withAnimation {
                    self.authors = authors
                }
                networker.mangaAuthorsCache[id] = self.authors
            }
        } catch {
            print("Some unknown error occurred loading manga authors")
        }
    }
    
    func loadRelated() async {
        do {
            if let relatedItems = networker.mangaRelatedCache[id] {
                withAnimation {
                    self.relatedItems = relatedItems
                }
            } else {
                let relations = try await networker.getMangaRelations(id: id)
                var relatedItems = relations.filter{ $0.relation == "Prequel" || $0.relation == "Sequel" || $0.relation == "Adaptation" }.flatMap{ category in category.entry.map{ RelatedItem(malId: $0.malId, type: $0.type, title: $0.name, enTitle: nil, url: $0.url, relation: category.relation, imageUrl: nil) } }
                relatedItems = try await relatedItems.concurrentMap { item in
                    var newItem = item
                    if item.type == .anime {
                        let anime = try await NetworkManager.shared.getAnimeDetails(id: item.id)
                        newItem.imageUrl = anime.mainPicture?.large
                        newItem.enTitle = anime.alternativeTitles?.en
                    } else if item.type == .manga {
                        let manga = try await NetworkManager.shared.getMangaDetails(id: item.id)
                        newItem.imageUrl = manga.mainPicture?.large
                        newItem.enTitle = manga.alternativeTitles?.en
                    }
                    return newItem
                }
                withAnimation {
                    self.relatedItems = relatedItems
                }
                networker.mangaRelatedCache[id] = relatedItems
            }
        } catch {
            print("Some unknown error occurred loading manga related items")
        }
    }
    
    func loadReviews() async {
        do {
            let reviews = try await networker.getMangaReviewsList(id: id, page: 1)
            withAnimation {
                self.reviews = reviews
            }
        } catch {
            print("Some unknown error occurred loading manga reviews")
        }
    }
}


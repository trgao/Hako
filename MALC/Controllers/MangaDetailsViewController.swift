//
//  MangaDetailsViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 12/5/24.
//

import Foundation
import Retry

@MainActor
class MangaDetailsViewController: ObservableObject {
    @Published var manga: Manga?
    @Published var characters = [ListCharacter]()
    @Published var authors = [Author]()
    @Published var relatedItems = [RelatedItem]()
    @Published var statistics: MangaStats?
    @Published var isLoading = false
    @Published var isLoadingError = false
    private let id: Int
    let networker = NetworkManager.shared
    
    init(id: Int) {
        self.id = id
        if let manga = networker.mangaCache[id] {
            self.manga = manga
        }
        Task {
            await refresh()
        }
    }
    
    // Refresh the current manga details page
    func refresh() async -> Void {
        isLoading = true
        isLoadingError = false
        do {
            let manga = try await networker.getMangaDetails(id: id)
            self.manga = manga
            networker.mangaCache[id] = manga
            isLoading = false
        } catch {
            isLoading = false
            isLoadingError = true
        }
        
        // Load characters
        try? await retry {
            if let characters = networker.mangaCharactersCache[id] {
                self.characters = characters
            } else {
                do {
                    let characters = try await networker.getMangaCharacters(id: id)
                    self.characters = characters
                    networker.mangaCharactersCache[id] = characters
                } catch {
                    print("Some unknown error occurred loading characters")
                }
            }
        }
        
        // Load authors
        try? await retry {
            if let authors = networker.mangaAuthorsCache[id] {
                self.authors = authors
            } else {
                var authors = manga?.authors ?? [];
                do {
                    authors = try await authors.concurrentMap { author in
                        var newAuthor = author
                        let person = try await self.networker.getPersonDetails(id: author.id)
                        newAuthor.imageUrl = person.images.jpg.imageUrl
                        return newAuthor
                    }
                    self.authors = authors
                    networker.mangaAuthorsCache[id] = authors
                } catch {
                    print("Some unknown error occurred loading authors")
                }
            }
        }
        
        // Load related
        try? await retry {
            if let relatedItems = networker.mangaRelatedCache[id] {
                self.relatedItems = relatedItems
            } else {
                do {
                    let relations = try await networker.getMangaRelations(id: id)
                    var relatedItems = relations.filter{ $0.relation == "Prequel" || $0.relation == "Sequel" || $0.relation == "Adaptation" }.flatMap{ category in category.entry.map{ RelatedItem(malId: $0.malId, type: $0.type, name: $0.name, url: $0.url, relation: category.relation, imageUrl: nil) } }
                    relatedItems = try await relatedItems.concurrentMap { item in
                        var newItem = item
                        if item.type == .anime {
                            let anime = try await NetworkManager.shared.getAnimeDetails(id: item.id)
                            newItem.imageUrl = anime.mainPicture?.medium
                        } else if item.type == .manga {
                            let manga = try await NetworkManager.shared.getMangaDetails(id: item.id)
                            newItem.imageUrl = manga.mainPicture?.medium
                        }
                        return newItem
                    }
                    self.relatedItems = relatedItems
                    networker.mangaRelatedCache[id] = relatedItems
                } catch {
                    print("Some unknown error occurred loading related")
                }
            }
        }
        
        // Load statistics
        try? await retry {
            if let statistics = networker.mangaStatsCache[id] {
                self.statistics = statistics
            } else {
                do {
                    self.statistics = try await networker.getMangaStatistics(id: self.id)
                    networker.mangaStatsCache[id] = statistics
                } catch {
                    print("Some unknown error occurred loading manga statistics")
                }
            }
        }
    }
}


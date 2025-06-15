//
//  AnimeDetailsViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 29/4/24.
//

import Foundation
import Retry

@MainActor
class AnimeDetailsViewController: ObservableObject {
    @Published var anime: Anime?
    @Published var characters = [ListCharacter]()
    @Published var staffs = [Staff]()
    @Published var relatedItems = [RelatedItem]()
    @Published var reviews = [Review]()
    @Published var statistics: AnimeStats?
    @Published var isLoading = false
    @Published var isLoadingError = false
    private let id: Int
    let networker = NetworkManager.shared
    
    init(id: Int) {
        self.id = id
        if let anime = networker.animeCache[id] {
            self.anime = anime
        }
        Task {
            await refresh()
        }
    }
    
    // Refresh the current anime details page
    func refresh() async -> Void {
        isLoading = true
        isLoadingError = false
        do {
            let anime = try await networker.getAnimeDetails(id: id)
            self.anime = anime
            networker.animeCache[id] = anime
        } catch {
            isLoadingError = true
        }
        isLoading = false
        
        // Load characters
        try? await retry {
            if let characters = networker.animeCharactersCache[id] {
                self.characters = characters
            } else {
                do {
                    let characters = try await networker.getAnimeCharacters(id: id)
                    self.characters = characters
                    networker.animeCharactersCache[id] = characters
                } catch {
                    print("Some unknown error occurred loading characters")
                }
            }
        }
        
        // Load staffs
        try? await retry {
            if let staffs = networker.animeStaffsCache[id] {
                self.staffs = staffs
            } else {
                do {
                    let staffs = try await networker.getAnimeStaff(id: id)
                    self.staffs = staffs
                    networker.animeStaffsCache[id] = staffs
                } catch {
                    print("Some unknown error occurred loading staffs")
                }
            }
        }
        
        // Load related
        try? await retry {
            if let relatedItems = networker.animeRelatedCache[id] {
                self.relatedItems = relatedItems
            } else {
                do {
                    let relations = try await networker.getAnimeRelations(id: id)
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
                    self.relatedItems = relatedItems
                    networker.animeRelatedCache[id] = relatedItems
                } catch {
                    print("Some unknown error occurred loading related")
                }
            }
        }
        
        // Load reviews
        try? await retry {
            do {
                let reviews = try await networker.getAnimeReviewsList(id: id, page: 1)
                self.reviews = reviews
            } catch {
                print("Some unknown error occurred loading anime reviews")
            }
        }
        
        // Load statistics
        try? await retry {
            if let statistics = networker.animeStatsCache[id] {
                self.statistics = statistics
            } else {
                do {
                    let statistics = try await networker.getAnimeStatistics(id: id)
                    self.statistics = statistics
                    networker.animeStatsCache[id] = statistics
                } catch {
                    print("Some unknown error occurred loading anime statistics")
                }
            }
        }
    }
}

//
//  AnimeDetailsViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

@MainActor
class AnimeDetailsViewController: ObservableObject {
    @Published var anime: Anime?
    @Published var nextEpisode: NextAiringEpisode?
    @Published var characters = [ListCharacter]()
    @Published var staffs = [Staff]()
    @Published var relatedItems = [RelatedItem]()
    @Published var reviews = [Review]()
    @Published var isLoading = true
    @Published var isLoadingError = false
    private let id: Int
    let networker = NetworkManager.shared
    
    init(id: Int) {
        self.id = id
        Task {
            await loadCachedDetails()
        }
    }
    
    init(anime: Anime) {
        self.id = anime.id
        self.anime = anime
        Task {
            await loadCachedDetails()
        }
    }
    
    // Refresh the current anime details page
    func refresh() async {
        if Task.isCancelled {
            return
        }
        await loadDetails()
        
        if Task.isCancelled {
            return
        }
        Task {
            await loadAiringSchedule()
        }
        
        if Task.isCancelled {
            return
        }
        await loadCharacters()
        
        if Task.isCancelled {
            return
        }
        await loadStaffs()
        
        if Task.isCancelled {
            return
        }
        await loadRelated()
        
        if Task.isCancelled {
            return
        }
        await loadReviews()
    }
    
    func loadCachedDetails() async {
        if let anime = networker.animeCache[id] {
            self.anime = anime
        }
        
        isLoading = true
        isLoadingError = false
        do {
            let anime = try await networker.getAnimeDetails(id: id)
            self.anime = anime
            networker.animeCache[id] = anime
        } catch {
            if case NetworkError.notFound = error {} else {
                isLoadingError = true
            }
        }
        isLoading = false
    }
    
    func loadDetails() async {
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
    }
    
    func loadAiringSchedule() async {
        do {
            if let nextEpisode = networker.animeNextEpisodeCache[id] {
                withAnimation {
                    self.nextEpisode = nextEpisode
                }
            } else {
                let nextEpisode = try await networker.getAnimeNextAiringDetails(id: id)
                withAnimation {
                    self.nextEpisode = nextEpisode
                }
                networker.animeNextEpisodeCache[id] = nextEpisode
            }
        } catch {
            print("Some unknown error occurred loading anime airing schedule")
        }
    }
    
    func loadCharacters() async {
        do {
            if let characters = networker.animeCharactersCache[id] {
                withAnimation {
                    self.characters = characters
                }
            } else {
                let characters = try await networker.getAnimeCharacters(id: id)
                withAnimation {
                    self.characters = characters
                }
                networker.animeCharactersCache[id] = characters
            }
        } catch {
            print("Some unknown error occurred loading anime characters")
        }
    }
    
    func loadStaffs() async {
        do {
            if let staffs = networker.animeStaffsCache[id] {
                withAnimation {
                    self.staffs = staffs
                }
            } else {
                let staffs = try await networker.getAnimeStaff(id: id)
                withAnimation {
                    self.staffs = staffs
                }
                networker.animeStaffsCache[id] = staffs
            }
        } catch {
            print("Some unknown error occurred loading anime staffs")
        }
    }
    
    func loadRelated() async {
        do {
            if let relatedItems = networker.animeRelatedCache[id] {
                withAnimation {
                    self.relatedItems = relatedItems
                }
            } else {
                let relations = try await networker.getAnimeRelations(id: id)
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
                withAnimation {
                    self.relatedItems = relatedItems
                }
                networker.animeRelatedCache[id] = relatedItems
            }
        } catch {
            print("Some unknown error occurred loading anime related items")
        }
    }
    
    func loadReviews() async {
        do {
            let reviews = try await networker.getAnimeReviewsList(id: id, page: 1)
            withAnimation {
                self.reviews = reviews
            }
        } catch {
            print("Some unknown error occurred loading anime reviews")
        }
    }
}

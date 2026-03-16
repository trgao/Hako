//
//  AnimeDetailsViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

@MainActor
class AnimeDetailsViewController: ObservableObject {
    // Data
    @Published var anime: Anime?
    @Published var nextEpisode: NextAiringEpisode?
    @Published var characters: [ListCharacter]?
    @Published var staffs: [Staff]?
    @Published var relatedItems: [RelatedItem]?
    @Published var reviews: [Review]?
    
    // Loading states
    @Published var loadingState: LoadingEnum = .loading
    @Published var charactersLoadingState: LoadingEnum = .loading
    @Published var staffsLoadingState: LoadingEnum = .loading
    @Published var relatedLoadingState: LoadingEnum = .loading
    @Published var reviewsLoadingState: LoadingEnum = .loading
    
    private let id: Int
    private let networker = NetworkManager.shared
    
    init(id: Int) {
        self.id = id
        if let anime = networker.animeCache[id] {
            self.anime = anime
        }
        Task {
            await loadDetails()
        }
    }
    
    init(anime: Anime) {
        self.id = anime.id
        self.anime = anime
        if let anime = networker.animeCache[id] {
            self.anime = anime
        }
        Task {
            await loadDetails()
        }
    }
    
    // Refresh the current anime details page
    func refresh() async {
        charactersLoadingState = .loading
        staffsLoadingState = .loading
        relatedLoadingState = .loading
        reviewsLoadingState = .loading
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
    
    func loadDetails() async {
        loadingState = .loading
        do {
            let anime = try await networker.getAnimeDetails(id: id)
            self.anime = anime
            networker.animeCache[id] = anime
            loadingState = .idle
        } catch {
            if case NetworkError.notFound = error {
                loadingState = .idle
            } else {
                loadingState = .error
            }
        }
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
        charactersLoadingState = .loading
        do {
            if let characters = networker.animeCharactersCache[id] {
                self.characters = characters
            } else {
                let characters = try await networker.getAnimeCharacters(id: id)
                self.characters = characters
                networker.animeCharactersCache[id] = characters
            }
            charactersLoadingState = .idle
        } catch {
            print("Some unknown error occurred loading anime characters")
            charactersLoadingState = .error
        }
    }
    
    func loadStaffs() async {
        staffsLoadingState = .loading
        do {
            if let staffs = networker.animeStaffsCache[id] {
                self.staffs = staffs
            } else {
                let staffs = try await networker.getAnimeStaff(id: id)
                self.staffs = staffs
                networker.animeStaffsCache[id] = staffs
            }
            staffsLoadingState = .idle
        } catch {
            print("Some unknown error occurred loading anime staffs")
            staffsLoadingState = .error
        }
    }
    
    func loadRelated() async {
        relatedLoadingState = .loading
        do {
            if let relatedItems = networker.animeRelatedCache[id] {
                self.relatedItems = relatedItems
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
                self.relatedItems = relatedItems
                networker.animeRelatedCache[id] = relatedItems
            }
            relatedLoadingState = .idle
        } catch {
            print("Some unknown error occurred loading anime related items")
            relatedLoadingState = .error
        }
    }
    
    func loadReviews() async {
        reviewsLoadingState = .loading
        do {
            let reviews = try await networker.getAnimeReviewsList(id: id, page: 1)
            self.reviews = reviews
            reviewsLoadingState = .idle
        } catch {
            print("Some unknown error occurred loading anime reviews")
            reviewsLoadingState = .error
        }
    }
}

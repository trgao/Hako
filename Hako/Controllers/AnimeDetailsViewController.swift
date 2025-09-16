//
//  AnimeDetailsViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 29/4/24.
//

import Foundation

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
        if let anime = networker.animeCache[id] {
            self.anime = anime
        }
        Task {
            await loadDetails()
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
                self.nextEpisode = nextEpisode
            } else {
                let nextEpisode = try await networker.getAnimeNextAiringDetails(id: id)
                self.nextEpisode = nextEpisode
                networker.animeNextEpisodeCache[id] = nextEpisode
            }
        } catch {
            print("Some unknown error occurred loading anime airing schedule")
        }
    }
    
    func loadCharacters() async {
        do {
            if let characters = networker.animeCharactersCache[id] {
                self.characters = characters
            } else {
                let characters = try await networker.getAnimeCharacters(id: id)
                self.characters = characters
                networker.animeCharactersCache[id] = characters
            }
        } catch {
            print("Some unknown error occurred loading anime characters")
        }
    }
    
    func loadStaffs() async {
        do {
            if let staffs = networker.animeStaffsCache[id] {
                self.staffs = staffs
            } else {
                let staffs = try await networker.getAnimeStaff(id: id)
                self.staffs = staffs
                networker.animeStaffsCache[id] = staffs
            }
        } catch {
            print("Some unknown error occurred loading anime staffs")
        }
    }
    
    func loadRelated() async {
        do {
            if let relatedItems = networker.animeRelatedCache[id] {
                self.relatedItems = relatedItems
            } else {
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
            }
        } catch {
            print("Some unknown error occurred loading anime related items")
        }
    }
    
    func loadReviews() async {
        do {
            self.reviews = try await networker.getAnimeReviewsList(id: id, page: 1)
        } catch {
            print("Some unknown error occurred loading anime reviews")
        }
    }
}

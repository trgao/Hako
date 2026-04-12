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
    @Published var relatedAnime: [RelatedItem]?
    @Published var relatedManga: [RelatedItem]?
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
        loadingState = .loading
        charactersLoadingState = .loading
        staffsLoadingState = .loading
        relatedLoadingState = .loading
        reviewsLoadingState = .loading
        
        await loadDetails()
        Task {
            await loadAiringSchedule()
        }
        await loadCharacters()
        await loadStaffs()
        await loadRelatedManga()
        await loadReviews()
    }
    
    func loadDetails() async {
        loadingState = .loading
        do {
            let anime = try await networker.getAnimeDetails(id: id)
            withAnimation {
                self.anime = anime
                var prequels: [RelatedItem] = [], sequels: [RelatedItem] = [], others: [RelatedItem] = []
                anime.relatedAnime?.forEach {
                    let item = RelatedItem(malId: $0.id, type: .anime, title: $0.node.title, relation: $0.relationTypeFormatted, anime: $0.node)
                    if item.relation == "Prequel" {
                        prequels.append(item)
                    } else if item.relation == "Sequel" {
                        sequels.append(item)
                    } else {
                        others.append(item)
                    }
                }
                self.relatedAnime = prequels + sequels + others.sorted(by: { ($0.relation ?? "") < ($1.relation ?? "") })
            }
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
        guard anime?.status != "finished_airing" else {
            return
        }
        
        if let nextEpisode = networker.animeNextEpisodeCache[id] {
            withAnimation {
                self.nextEpisode = nextEpisode
            }
            return
        }
        
        do {
            let nextEpisode = try await networker.getAnimeNextAiringDetails(id: id)
            withAnimation {
                self.nextEpisode = nextEpisode
            }
            networker.animeNextEpisodeCache[id] = nextEpisode
        } catch {
            print("Some unknown error occurred loading anime airing schedule")
        }
    }
    
    func loadCharacters() async {
        if let characters = networker.animeCharactersCache[id] {
            self.characters = characters
            charactersLoadingState = .idle
            return
        }
        
        charactersLoadingState = .loading
        do {
            let characters = try await networker.getAnimeCharacters(id: id)
            self.characters = characters
            networker.animeCharactersCache[id] = characters
            charactersLoadingState = .idle
        } catch {
            charactersLoadingState = .error
        }
    }
    
    func loadStaffs() async {
        if let staffs = networker.animeStaffsCache[id] {
            self.staffs = staffs
            staffsLoadingState = .idle
            return
        }
        
        staffsLoadingState = .loading
        do {
            let staffs = try await networker.getAnimeStaff(id: id)
            self.staffs = staffs
            networker.animeStaffsCache[id] = staffs
            staffsLoadingState = .idle
        } catch {
            staffsLoadingState = .error
        }
    }
    
    func loadRelatedManga() async {
        if let relatedManga = networker.animeRelatedMangaCache[id] {
            self.relatedManga = relatedManga
            relatedLoadingState = .idle
            return
        }
        
        relatedLoadingState = .loading
        do {
            self.relatedManga = try await networker.getAnimeRelations(id: id)
                .flatMap{ category in category.entry.map{ RelatedItem(malId: $0.malId, type: $0.type, title: $0.name, relation: category.relation?.lowercased().initialCapitalise(), anime: nil, manga: nil) } }
                .filter { $0.type == .manga }
            relatedLoadingState = .idle
            if let items = relatedManga {
                var loaded = Array(repeating: true, count: items.count)
                await items.indices.concurrentForEach { i in
                    if let manga = self.networker.mangaCache[items[i].id] {
                        self.relatedManga?[i].manga = manga
                    } else if let manga = try? await self.networker.getMangaDetails(id: items[i].id) {
                        self.relatedManga?[i].manga = manga
                        self.networker.mangaCache[items[i].id] = manga
                    } else {
                        loaded[i] = false
                    }
                }
                
                // Only store to cache if all is loaded
                if loaded.reduce(true, { $0 && $1 }) {
                    networker.animeRelatedMangaCache[id] = relatedManga
                }
            }
        } catch {
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
            reviewsLoadingState = .error
        }
    }
}

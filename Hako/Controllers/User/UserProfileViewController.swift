//
//  UserProfileViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 22/11/24.
//

import SwiftUI

@MainActor
class UserProfileViewController: ObservableObject {
    // Data
    @Published var userStatistics: UserStatistics?
    @Published var anime: [MALListAnime]?
    @Published var manga: [MALListManga]?
    @Published var characters: [JikanListItem]?
    @Published var people: [JikanListItem]?
    
    // Loading states
    @Published var loadingState: LoadingEnum = .loading
    @Published var favouritesLoadingState: LoadingEnum = .loading
    
    @Published var isUserNotFound = false
    private let user: String?
    private let networker = NetworkManager.shared
    
    init(user: String? = nil) {
        self.user = user
        Task {
            await loadStatistics()
        }
    }
    
    func refresh() async {
        favouritesLoadingState = .loading
        await loadStatistics()
        if isUserNotFound {
            favouritesLoadingState = .idle
            return
        }
        await loadFavourites()
    }
    
    private func loadStatistics() async {
        loadingState = .loading
        do {
            self.userStatistics = try await networker.getUserStatistics(user: user)
            loadingState = .idle
        } catch {
            if case NetworkError.notFound = error {
                isUserNotFound = true
                loadingState = .idle
            } else {
                loadingState = .error
            }
        }
    }
    
    func loadFavourites() async {
        favouritesLoadingState = .loading
        do {
            let userFavourites = try await networker.getUserFavourites(user: user)
            self.anime = userFavourites.anime?.map { MALListAnime(anime: Anime(item: $0)) }
            self.manga = userFavourites.manga?.map { MALListManga(manga: Manga(item: $0)) }
            self.characters = userFavourites.characters
            self.people = userFavourites.people
            favouritesLoadingState = .idle
            
            if let anime = anime {
                await anime.indices.concurrentForEach { i in
                    if let details = self.networker.animeCache[anime[i].id] {
                        self.anime?[i] = MALListAnime(anime: details)
                    } else if let details = try? await NetworkManager.shared.getAnimeDetails(id: anime[i].id) {
                        self.anime?[i] = MALListAnime(anime: details)
                    }
                }
            }
            
            if let manga = manga {
                await manga.indices.concurrentForEach { i in
                    if let details = self.networker.mangaCache[manga[i].id] {
                        self.manga?[i] = MALListManga(manga: details)
                    } else if let details = try? await NetworkManager.shared.getMangaDetails(id: manga[i].id) {
                        self.manga?[i] = MALListManga(manga: details)
                    }
                }
            }
        } catch {
            favouritesLoadingState = .error
        }
    }
}

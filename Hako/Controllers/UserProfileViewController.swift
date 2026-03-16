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
            print("Some unknown error occurred loading user statistics")
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
            self.characters = userFavourites.characters
            self.people = userFavourites.people
            
            let anime = try await userFavourites.anime?.concurrentMap { anime in
                let anime = try await NetworkManager.shared.getAnimeDetails(id: anime.id)
                return MALListAnime(anime: anime)
            }
            self.anime = anime
            
            let manga = try await userFavourites.manga?.concurrentMap { manga in
                let manga = try await NetworkManager.shared.getMangaDetails(id: manga.id)
                return MALListManga(manga: manga)
            }
            self.manga = manga
            
            favouritesLoadingState = .idle
        } catch {
            print("Some unknown error occurred loading user favourites")
            favouritesLoadingState = .error
        }
    }
}

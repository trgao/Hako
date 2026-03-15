//
//  UserProfileViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 22/11/24.
//

import SwiftUI

@MainActor
class UserProfileViewController: ObservableObject {
    @Published var userStatistics: UserStatistics?
    @Published var userFavourites: UserFavourites?
    @Published var anime: [MALListAnime] = []
    @Published var manga: [MALListManga] = []
    @Published var loadingState: LoadingEnum = .loading
    @Published var isUserNotFound = false
    private let user: String?
    private let networker = NetworkManager.shared
    
    init(user: String? = nil) {
        self.user = user
    }
    
    func refresh() async {
        loadingState = .loading
        var hasNoError = true
        do {
            self.userStatistics = try await networker.getUserStatistics(user: user)
        } catch {
            print("Some unknown error occurred loading user statistics")
            if case NetworkError.notFound = error {
                isUserNotFound = true
                loadingState = .idle
                return
            } else {
                loadingState = .error
                hasNoError = false
            }
        }
        
        do {
            let userFavourites = try await networker.getUserFavourites(user: user)
            withAnimation {
                self.userFavourites = userFavourites
            }
            let anime = try await userFavourites.anime.concurrentMap { anime in
                let anime = try await NetworkManager.shared.getAnimeDetails(id: anime.id)
                return MALListAnime(anime: anime)
            }
            withAnimation {
                self.anime = anime
            }
            let manga = try await userFavourites.manga.concurrentMap { manga in
                let manga = try await NetworkManager.shared.getMangaDetails(id: manga.id)
                return MALListManga(manga: manga)
            }
            withAnimation {
                self.manga = manga
            }
        } catch {
            print("Some unknown error occurred loading user favourites")
            hasNoError = false
            loadingState = .error
        }
        if hasNoError {
            loadingState = .idle
        }
    }
}

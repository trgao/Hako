//
//  ProfileViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 22/11/24.
//

import Foundation
import Retry

@MainActor
class ProfileViewController: ObservableObject {
    @Published var userStatistics: UserStatistics?
    @Published var userFavourites: UserFavourites?
    @Published var anime = [MALListAnime]()
    @Published var manga = [MALListManga]()
    let networker = NetworkManager.shared
    
    func refresh() async -> Void {
        do {
            try await retry {
                self.userStatistics = try await networker.getUserStatistics()
            }
        } catch {
            print("Some unknown error occurred loading user statistics")
        }
        
        do {
            try await retry {
                self.userFavourites = try await networker.getUserFavourites()
                
                self.anime = try await userFavourites?.anime.concurrentMap { anime in
                    let anime = try await NetworkManager.shared.getAnimeDetails(id: anime.id)
                    return MALListAnime(anime: anime)
                } ?? []
                self.manga = try await userFavourites?.manga.concurrentMap { manga in
                    let manga = try await NetworkManager.shared.getMangaDetails(id: manga.id)
                    return MALListManga(manga: manga)
                } ?? []
            }
        } catch {
            print("Some unknown error occurred loading user favourites")
        }
    }
}

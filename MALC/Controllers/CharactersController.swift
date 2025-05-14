//
//  CharactersController.swift
//  MALC
//
//  Created by Gao Tianrun on 19/5/24.
//

import Foundation

@MainActor
class CharactersController: ObservableObject {
    @Published var characters: [ListCharacter] = []
    @Published var isLoading = false
    let networker = NetworkManager.shared
    
    init(id: Int, type: TypeEnum) {
        if type == .anime, let characters = networker.animeCharactersCache[id] {
            self.characters = characters
        } else if type == .manga, let characters = networker.mangaCharactersCache[id] {
            self.characters = characters
        } else {
            self.isLoading = true
            Task {
                do {
                    if type == .anime {
                        let characters = try await networker.getAnimeCharacters(id: id)
                        self.characters = characters
                        networker.animeCharactersCache[id] = characters
                    } else if type == .manga {
                        let characters = try await networker.getMangaCharacters(id: id)
                        self.characters = characters
                        networker.mangaCharactersCache[id] = characters
                    }
                    self.isLoading = false
                } catch {
                    self.isLoading = false
                }
            }
        }
    }
}

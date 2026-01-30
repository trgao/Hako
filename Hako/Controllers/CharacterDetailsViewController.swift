//
//  CharacterDetailsViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 2/5/24.
//

import Foundation

@MainActor
class CharacterDetailsViewController: ObservableObject {
    @Published var character: Character?
    @Published var loadingState: LoadingEnum = .loading
    private let id: Int
    let networker = NetworkManager.shared
    
    init(id: Int) {
        self.id = id
        if let character = networker.characterCache[id] {
            self.character = character
        }
        Task {
            await refresh()
        }
    }
    
    init(id: Int, name: String?) {
        self.id = id
        self.character = Character(id: id, name: name)
        if let character = networker.characterCache[id] {
            self.character = character
        }
        Task {
            await refresh()
        }
    }
    
    // Refresh the current character details page
    func refresh() async {
        loadingState = .loading
        do {
            let character = try await networker.getCharacterDetails(id: id)
            self.character = character
            networker.characterCache[id] = character
            loadingState = .idle
        } catch {
            if case NetworkError.notFound = error {
                loadingState = .idle
            } else {
                loadingState = .error
            }
        }
    }
}

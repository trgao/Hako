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
    @Published var isLoading = false
    @Published var isLoadingError = false
    private let id: Int
    let networker = NetworkManager.shared
    
    init(id: Int) {
        self.id = id
        Task {
            await refresh()
        }
    }
    
    // Refresh the current character details page
    func refresh() async -> Void {
        isLoading = true
        do {
            let character = try await networker.getCharacterDetails(id: id)
            self.character = character
        } catch {
            isLoadingError = true
        }
        isLoading = false
    }
}

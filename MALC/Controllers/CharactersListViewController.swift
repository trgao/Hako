//
//  CharactersListViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 2/5/24.
//

import Foundation

@MainActor
class CharactersListViewController: ObservableObject {
    @Published var isLoading = false
    private let characters: [ListCharacter]
    let networker = NetworkManager.shared
    
    init(characters: [ListCharacter]) {
        self.characters = characters
    }
    
    func loadImages() async -> Void {
        isLoading = true
        
        isLoading = false
    }
}

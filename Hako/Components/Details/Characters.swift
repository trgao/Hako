//
//  Characters.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct Characters: View {
    @EnvironmentObject private var settings: SettingsManager
    private let characters: [ListCharacter]?
    private let loadingState: LoadingEnum
    private let load: () async -> Void
    
    init(characters: [ListCharacter]?, loadingState: LoadingEnum, load: @escaping () async -> Void) {
        self.characters = characters
        self.loadingState = loadingState
        self.load = load
    }
    
    var body: some View {
        ScrollViewCarousel(title: "Characters", count: characters?.count, loadingState: loadingState, refresh: load, placeholder: SmallPlaceholderGridItem.init) {
            ForEach((characters ?? []).prefix(10)) { character in
                CharacterGridItem(id: character.id, name: character.character.name, imageUrl: character.character.images?.jpg?.imageUrl)
            }
        } destination: {
            CharactersListView(characters: characters ?? [])
        }
        .task {
            await load()
        }
    }
}

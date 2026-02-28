//
//  Characters.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct Characters: View {
    @EnvironmentObject private var settings: SettingsManager
    private let characters: [ListCharacter]
    private let load: () async -> Void
    
    init(characters: [ListCharacter], load: @escaping () async -> Void) {
        self.characters = characters
        self.load = load
    }
    
    var body: some View {
        VStack {
            if !characters.isEmpty {
                ScrollViewCarousel(title: "Characters", count: characters.count, spacing: 15) {
                    ForEach(characters.prefix(10)) { character in
                        CharacterGridItem(id: character.id, name: character.character.name, imageUrl: character.character.images?.jpg?.imageUrl)
                    }
                } destination: {
                    CharactersListView(characters: characters)
                }
            }
        }
        .task {
            await load()
        }
    }
}

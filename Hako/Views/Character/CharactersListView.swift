//
//  CharactersListView.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct CharactersListView: View {
    private let characters: [ListCharacter]
    
    init(characters: [ListCharacter]) {
        self.characters = characters
    }
    
    var body: some View {
        List {
            ForEach(characters) { character in
                CharacterListItem(character: character)
            }
        }
        .navigationTitle("Characters")
    }
}

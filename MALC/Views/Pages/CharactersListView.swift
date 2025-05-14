//
//  CharactersListView.swift
//  MALC
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
        ZStack {
            List {
                ForEach(characters) { character in
                    NavigationLink {
                        CharacterDetailsView(id: character.id, imageUrl: character.character.images?.jpg.imageUrl)
                    } label: {
                        HStack {
                            ImageFrame(id: "character\(character.id)", imageUrl: character.character.images?.jpg.imageUrl, imageSize: .small)
                                .padding([.trailing], 10)
                            Text(character.character.name ?? "")
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Characters")
        }
    }
}

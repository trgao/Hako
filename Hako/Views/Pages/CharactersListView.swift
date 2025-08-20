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
                NavigationLink {
                    CharacterDetailsView(id: character.id)
                } label: {
                    HStack {
                        ImageFrame(id: "character\(character.id)", imageUrl: character.character.images?.jpg?.imageUrl, imageSize: .small)
                            .padding(.trailing, 10)
                        VStack(alignment: .leading, spacing: 5) {
                            Text(character.character.name ?? "")
                            Text(character.role ?? "")
                                .foregroundStyle(Color(.systemGray))
                                .font(.system(size: 13))
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Characters")
    }
}

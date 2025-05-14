//
//  Characters.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct Characters: View {
    private let characters: [ListCharacter]
    let networker = NetworkManager.shared
    
    init(characters: [ListCharacter]) {
        self.characters = characters
    }
    
    var body: some View {
        if !characters.isEmpty {
            Section {} header: {
                VStack {
                    NavigationLink {
                        CharactersListView(characters: characters)
                    } label: {
                        HStack {
                            Text("Characters")
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color(.systemGray2))
                        }
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 30)
                        .font(.system(size: 17))
                    }
                    .buttonStyle(.plain)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            Rectangle()
                                .frame(width: 5)
                                .foregroundColor(.clear)
                            ForEach(characters.prefix(10)) { character in
                                ZoomTransition {
                                    CharacterDetailsView(id: character.id, imageUrl: character.character.images?.jpg.imageUrl)
                                } label: {
                                    VStack {
                                        ImageFrame(id: "character\(character.id)", imageUrl: character.character.images?.jpg.imageUrl, imageSize: .medium)
                                        Text(character.character.name ?? "")
                                            .font(.system(size: 14))
                                    }
                                    .frame(width: 120)
                                }
                            }
                            Rectangle()
                                .frame(width: 5)
                                .foregroundColor(.clear)
                        }
                    }
                    
                }
                .textCase(nil)
                .padding(.horizontal, -15)
                .foregroundColor(Color.primary)
                .listRowInsets(.init())
            }
            .listRowInsets(.init())
        }
    }
}

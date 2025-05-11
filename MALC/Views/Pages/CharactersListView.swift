//
//  CharactersListView.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct CharactersListView: View {
    @StateObject var controller: CharactersListViewController
    private let characters: [ListCharacter]
    
    init(characters: [ListCharacter]) {
        self.characters = characters
        self._controller = StateObject(wrappedValue: CharactersListViewController(characters: characters))
    }
    
    var body: some View {
        ZStack {
            List {
                ForEach(characters) { character in
                    NavigationLink {
                        CharacterDetailsView(id: character.id, imageUrl: character.character.images?.jpg.imageUrl)
                    } label: {
                        HStack {
                            ImageFrame(id: "character\(character.id)", width: 75, height: 106)
                                .padding([.trailing], 10)
                            Text(character.character.name ?? "")
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Characters")
            .background(Color(.systemGray6))
            if controller.isLoading {
                LoadingView()
            }
        }
        .task {
            await controller.loadImages()
        }
    }
}

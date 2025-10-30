//
//  AnimeCharacters.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct AnimeCharacters: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller: AnimeDetailsViewController
    let networker = NetworkManager.shared
    
    init(controller: AnimeDetailsViewController) {
        self._controller = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        VStack {
            if !controller.characters.isEmpty {
                ScrollViewCarousel(title: "Characters", items: controller.characters) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 15) {
                            ForEach(controller.characters.prefix(10)) { character in
                                CharacterGridItem(id: character.id, name: character.character.name, imageUrl: character.character.images?.jpg?.imageUrl)
                            }
                        }
                        .padding(.horizontal, 17)
                        .padding(.top, 50)
                    }
                    .padding(.top, -50)
                } destination: {
                    CharactersListView(characters: controller.characters)
                }
            }
        }
        .task {
            await controller.loadCharacters()
        }
    }
}

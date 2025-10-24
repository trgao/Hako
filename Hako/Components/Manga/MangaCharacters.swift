//
//  MangaCharacters.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct MangaCharacters: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller: MangaDetailsViewController
    let networker = NetworkManager.shared
    
    init(controller: MangaDetailsViewController) {
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
                    }
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

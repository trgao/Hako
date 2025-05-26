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
        if !controller.characters.isEmpty {
            Section {} header: {
                VStack {
                    ListViewLink(title: "Characters", items: controller.characters) {
                        CharactersListView(characters: controller.characters)
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            ForEach(controller.characters.prefix(10)) { character in
                                ZoomTransition {
                                    CharacterDetailsView(id: character.id)
                                } label: {
                                    VStack {
                                        ImageFrame(id: "character\(character.id)", imageUrl: character.character.images?.jpg?.imageUrl, imageSize: .medium)
                                        Text(character.character.name ?? "")
                                            .lineLimit(settings.getLineLimit())
                                            .font(.system(size: 14))
                                    }
                                    .frame(width: 120)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .textCase(nil)
                .padding(.horizontal, -20)
                .foregroundColor(Color.primary)
                .listRowInsets(.init())
            }
            .listRowInsets(.init())
        }
    }
}

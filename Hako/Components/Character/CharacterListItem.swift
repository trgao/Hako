//
//  CharacterListItem.swift
//  Hako
//
//  Created by Gao Tianrun on 24/10/25.
//

import SwiftUI

struct CharacterListItem: View {
    @EnvironmentObject private var settings: SettingsManager
    private let character: ThirdPartyListItem
    private let subtitle: String?
    private let item: Character

    init(character: ThirdPartyListItem) {
        self.character = character
        self.subtitle = character.nameKanji
        self.item = Character(id: character.id, name: character.name, imageUrl: character.images?.jpg?.imageUrl)
    }

    init(character: ListCharacter) {
        self.character = character.character
        self.subtitle = character.role
        self.item = Character(id: character.id, name: character.character.name, imageUrl: character.character.images?.jpg?.imageUrl)
    }

    var body: some View {
        TrackedNavigationLink(value: item) {
            HStack {
                ImageFrame(id: "character\(character.id)", imageUrl: character.images?.jpg?.imageUrl, imageSize: Constants.listImageSize)
                VStack(alignment: .leading, spacing: 5) {
                    Text(character.name ?? "")
                        .lineLimit(settings.getLineLimit())
                        .bold()
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .foregroundStyle(Color(.systemGray))
                            .font(.footnote)
                    }
                }
                .padding(5)
                .foregroundStyle(Color.primary)
            }
            .contextMenu {
                ShareLink(item: URL(string: "https://myanimelist.net/character/\(character.id)")!) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
        .padding(5)
    }
}

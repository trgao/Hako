//
//  CharacterListItem.swift
//  Hako
//
//  Created by Gao Tianrun on 24/10/25.
//

import SwiftUI

struct CharacterListItem: View {
    @EnvironmentObject private var settings: SettingsManager
    private let character: JikanListItem
    private let subtitle: String?
    
    init(character: JikanListItem) {
        self.character = character
        self.subtitle = nil
    }
    
    init(character: ListCharacter) {
        self.character = character.character
        self.subtitle = character.role
    }
    
    var body: some View {
        NavigationLink {
            CharacterDetailsView(id: character.id, name: character.name)
        } label: {
            HStack {
                ImageFrame(id: "character\(character.id)", imageUrl: character.images?.jpg?.imageUrl, imageSize: .small)
                VStack(alignment: .leading, spacing: 5) {
                    Text(character.name ?? "")
                        .lineLimit(settings.getLineLimit())
                        .bold()
                        .font(.system(size: 16))
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .foregroundStyle(Color(.systemGray))
                            .font(.system(size: 13))
                    }
                }
                .padding(5)
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


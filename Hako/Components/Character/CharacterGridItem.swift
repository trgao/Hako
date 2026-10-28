//
//  CharacterGridItem.swift
//  Hako
//
//  Created by Gao Tianrun on 24/10/24.
//

import SwiftUI

struct CharacterGridItem: View {
    @Namespace private var namespace
    @Environment(\.screenRatio) private var screenRatio
    @EnvironmentObject private var settings: SettingsManager
    private let id: Int
    private let name: String?
    private let imageUrl: String?
    private let content: ZoomTransitionContent

    init(id: Int, name: String?, imageUrl: String?) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.content = ZoomTransitionContent(id: id, name: name, imageUrl: imageUrl, type: .character)
    }

    var body: some View {
        NavigationLink(value: Route.characterZoom(ZoomTransitionItem(content: content, namespaceId: namespace))) {
            VStack {
                ImageFrame(id: "character\(id)", imageUrl: imageUrl, imageSize: .medium)
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
                    .contextMenu {
                        ShareLink(item: URL(string: "https://myanimelist.net/character/\(id)")!) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }
                Text(name ?? "")
                    .lineLimit(settings.getLineLimit())
                    .font(.footnote)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
            .frame(width: 110 * screenRatio)
            .matchedTransitionSource(id: "character", in: namespace)

        }
        .buttonStyle(.plain)
        .id(id)
    }
}

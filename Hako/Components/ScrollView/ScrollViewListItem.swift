//
//  ScrollViewListItem.swift
//  Hako
//
//  Created by Gao Tianrun on 20/9/25.
//

import SwiftUI

struct ScrollViewListItem<Item: Hashable>: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(Router.self) private var router
    @State private var isPressed = false
    private let id: String
    private let title: String?
    private let subtitle: String?
    private let imageUrl: String?
    private let url: String
    private let item: Item
    private let itemId = UUID()

    init(id: String, title: String?, subtitle: String?, imageUrl: String?, url: String, item: Item) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        self.url = url
        self.item = item
    }

    var body: some View {
        HStack(spacing: 10) {
            ImageFrame(id: id, imageUrl: imageUrl, imageSize: Constants.listImageSize)
                .padding(.trailing, 10)
            HStack {
                VStack(alignment: .leading) {
                    Text(title ?? "")
                        .foregroundStyle(Color.primary)
                        .multilineTextAlignment(.leading)
                    Text(subtitle ?? "")
                        .foregroundStyle(Color(.systemGray))
                        .font(.footnote)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .bold()
                    .font(.caption)
                    .foregroundStyle(Color(.systemGray2))
            }
        }
        .id(itemId)
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
            isPressed = true
            router.push(item)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isPressed = false
            }
        }
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            isPressed = pressing
        }) {}
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(isPressed ? Color(.systemGray4) : (colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground)))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
        .contextMenu {
            ShareLink(item: URL(string: url)!) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
        .onAppear {
            isPressed = false
        }
    }
}

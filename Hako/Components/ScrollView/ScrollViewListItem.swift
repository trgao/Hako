//
//  ScrollViewListItem.swift
//  Hako
//
//  Created by Gao Tianrun on 20/9/25.
//

import SwiftUI

struct ScrollViewListItem: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding private var selectedIndex: Int?
    @State private var isPressed = false
    private let id: String
    private let title: String?
    private let subtitle: String?
    private let imageUrl: String?
    private let url: String
    private let index: Int
    
    init(id: String, title: String?, subtitle: String?, imageUrl: String?, url: String, index: Int, selectedIndex: Binding<Int?>) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        self.url = url
        self.index = index
        self._selectedIndex = selectedIndex
    }
    
    var body: some View {
        HStack(spacing: 10) {
            ImageFrame(id: id, imageUrl: imageUrl, imageSize: .small)
                .padding(.trailing, 10)
            HStack {
                VStack(alignment: .leading) {
                    Text(title ?? "")
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    Text(subtitle ?? "")
                        .foregroundStyle(Color(.systemGray))
                        .font(.system(size: 13))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .bold()
                    .font(.system(size: 12))
                    .foregroundStyle(Color(.systemGray2))
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
            selectedIndex = index
            isPressed = true
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

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
    private let index: Int
    init(id: String, title: String?, subtitle: String?, imageUrl: String?, index: Int, selectedIndex: Binding<Int?>) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
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
        .contentShape(Rectangle())
        .onTapGesture {
            selectedIndex = index
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(isPressed ? Color(.systemGray3) : (colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground)))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

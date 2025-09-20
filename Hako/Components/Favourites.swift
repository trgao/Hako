//
//  Favourites.swift
//  Hako
//
//  Created by Gao Tianrun on 16/6/25.
//

import SwiftUI

struct Favourites: View {
    @Environment(\.colorScheme) private var colorScheme
    private var favorites: Int?
    
    init(favorites: Int?) {
        self.favorites = favorites
    }
    
    var body: some View {
        if let favorites = favorites {
            HStack {
                Spacer()
                Label("\(favorites) favorites", systemImage: "star.fill")
                Spacer()
            }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = "\(favorites) favorites"
                    } label: {
                        Label("Copy", systemImage: "document.on.document")
                    }
                }
//                .padding(.horizontal, 17)
//                .padding(.bottom, 5)
        }
    }
}


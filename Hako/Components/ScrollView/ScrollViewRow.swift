//
//  ScrollViewRow.swift
//  Hako
//
//  Created by Gao Tianrun on 20/6/25.
//

import SwiftUI

struct ScrollViewRow: View {
    @Environment(\.colorScheme) private var colorScheme
    private let title: String
    private let content: String
    
    init(title: String, content: String) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        HStack {
            Text(title)
                .bold()
            Spacer()
            Text(content)
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
        .contextMenu {
            Button {
                UIPasteboard.general.string = content
            } label: {
                Label("Copy", systemImage: "document.on.document")
                Text(content)
            }
        }
    }
}

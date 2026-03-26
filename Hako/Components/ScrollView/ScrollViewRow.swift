//
//  ScrollViewRow.swift
//  Hako
//
//  Created by Gao Tianrun on 20/6/25.
//

import SwiftUI

struct ScrollViewRow: View {
    @Environment(\.colorScheme) private var colorScheme
    private let title: String?
    private let content: String
    
    init(title: String, content: String) {
        self.title = title
        self.content = content
    }
    
    init(_ content: String) {
        self.title = nil
        self.content = content
    }
    
    var body: some View {
        HStack {
            if let title = title {
                Text(title)
                    .bold()
                Spacer()
            }
            Text(content)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: title == nil ? .leading : .trailing)
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

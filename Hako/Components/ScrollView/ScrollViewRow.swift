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
    private let icon: String?
    
    init(title: String, content: String, icon: String? = nil) {
        self.title = title
        self.content = content
        self.icon = icon
    }
    
    init(_ content: String) {
        self.title = nil
        self.content = content
        self.icon = nil
    }
    
    var body: some View {
        HStack(alignment: .top) {
            if let title = title {
                Text(title)
                    .font(.footnote)
                    .opacity(0.7)
                Spacer()
            }
            Group {
                if let icon = icon {
                    Label(content, systemImage: icon)
                        .labelStyle(.reducedSpace)
                } else {
                    Text(content)
                }
            }
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
            }
        }
    }
}

//
//  StatisticsRow.swift
//  Hako
//
//  Created by Gao Tianrun on 20/6/25.
//

import SwiftUI

struct StatisticsRow<T>: View {
    @Environment(\.colorScheme) private var colorScheme
    private let title: String
    private let content: T?
    private let icon: String
    private let color: Color
    
    init(title: String, content: T?, icon: String, color: Color) {
        self.title = title
        self.content = content
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        let contextMenu = ContextMenu {
            if let content = content {
                Button {
                    UIPasteboard.general.string = String(describing: content)
                } label: {
                    Label("Copy", systemImage: "document.on.document")
                    Text(String(describing: content))
                }
            }
        }
        HStack {
            Label {
                Text(title)
                    .bold()
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                    .padding(.trailing, 10)
            }
            Spacer()
            if let content = content {
                Text(String(describing: content))
            } else {
                Text("example")
                    .skeleton()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
        .contextMenu(content == nil ? nil : contextMenu)
    }
}

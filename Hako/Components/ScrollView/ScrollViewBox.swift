//
//  ScrollViewBox.swift
//  Hako
//
//  Created by Gao Tianrun on 1/12/25.
//

import SwiftUI

struct ScrollViewBox: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.screenSize) private var screenSize
    @EnvironmentObject private var settings: SettingsManager
    @ScaledMetric private var height = 20
    private let title: String
    private let image: String
    private let content: String
    
    init(title: String, image: String, content: String) {
        self.title = title
        self.image = image
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Text(title)
                .font(.subheadline)
            Label(content, systemImage: image)
                .labelStyle(CustomLabelStyle())
                .bold()
                .frame(height: height)
        }
        .contentShape(Rectangle())
        .padding(10)
        .frame(maxWidth: .infinity)
        .frame(height: height + 55)
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

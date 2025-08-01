//
//  ScrollViewNavigationLink.swift
//  Hako
//
//  Created by Gao Tianrun on 20/6/25.
//

import SwiftUI

struct ScrollViewNavigationLink<Destination: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false
    private let title: String
    private let content: String
    private let destination: () -> Destination
    
    init(title: String, content: String = "", destination: @escaping () -> Destination) {
        self.title = title
        self.content = content
        self.destination = destination
    }
    
    var body: some View {
        HStack {
            Text(title)
                .bold()
            Spacer()
            Text(content)
            Image(systemName: "chevron.right")
                .bold()
                .font(.system(size: 12))
                .foregroundStyle(Color(.systemGray2))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isPressed = true
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .background(isPressed ? Color(.systemGray3) : (content == "" || colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground)))
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
        .contextMenu {
            if content != "" {
                Button {
                    UIPasteboard.general.string = content
                } label: {
                    Label("Copy", systemImage: "document.on.document")
                    Text(content)
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .navigationDestination(isPresented: $isPressed, destination: destination)
    }
}

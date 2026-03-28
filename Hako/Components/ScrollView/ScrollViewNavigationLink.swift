//
//  ScrollViewNavigationLink.swift
//  Hako
//
//  Created by Gao Tianrun on 20/6/25.
//

import SwiftUI
import WrappingHStack

struct ScrollViewNavigationLink<Destination: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false
    @State private var isLongPress = false
    private let title: String
    private let items: [String]
    private let content: String
    private let destination: () -> Destination
    
    init(title: String, items: [String], destination: @escaping () -> Destination) {
        self.title = title
        self.items = items
        self.content = items.joined(separator: ", ")
        self.destination = destination
    }
    
    var body: some View {
        HStack {
            HStack(alignment: .top) {
                Text(title)
                    .font(.footnote)
                    .opacity(0.7)
                Spacer()
                WrappingHStack(alignment: .trailing, horizontalSpacing: 4, verticalSpacing: 4) {
                    ForEach(items, id: \.self) { item in
                        TagItem(text: item)
                    }
                }
            }
            Image(systemName: "chevron.right")
                .bold()
                .font(.caption)
                .foregroundStyle(Color(.systemGray2))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isPressed = true
        }
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            isLongPress = pressing
        }) {}
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(isPressed || isLongPress ? Color(.systemGray4) : colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
        .contextMenu {
            Button {
                UIPasteboard.general.string = content
            } label: {
                Text("Copy")
                Text(content)
            }
        }
        .navigationDestination(isPresented: $isPressed, destination: destination)
    }
}

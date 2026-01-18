//
//  ScrollViewCarousel.swift
//  Hako
//
//  Created by Gao Tianrun on 20/6/25.
//

import SwiftUI

struct ScrollViewCarousel<Content: View, Destination: View, T>: View {
    @Environment(\.colorScheme) private var colorScheme
    private let title: String
    private let items: [T]
    private let showLink: Bool
    private let content: () -> Content
    private let destination: () -> Destination
    
    init(title: String, items: [T] = [""], showLink: Bool = true, @ViewBuilder content: @escaping () -> Content, destination: @escaping () -> Destination = { EmptyView() }) {
        self.title = title
        self.items = items
        self.showLink = showLink
        self.content = content
        self.destination = destination
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if items.count > 10 && showLink {
                NavigationLink {
                    destination()
                } label: {
                    HStack {
                        Text(title)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color(.systemGray2))
                    }
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.horizontal, 35)
                    .font(.callout)
                }
                .buttonStyle(.plain)
            } else {
                Text(title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.horizontal, 35)
                    .font(.callout)
            }
            content()
        }
    }
}

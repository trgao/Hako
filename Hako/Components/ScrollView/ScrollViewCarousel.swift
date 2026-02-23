//
//  ScrollViewCarousel.swift
//  Hako
//
//  Created by Gao Tianrun on 20/6/25.
//

import SwiftUI

struct ScrollViewCarousel<Content: View, Destination: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    private let title: String
    private let count: Int
    private let spacing: CGFloat?
    private let viewAlignedScroll: Bool
    private let content: () -> Content
    private let destination: () -> Destination
    
    init(title: String, count: Int = 0, spacing: CGFloat? = nil, viewAlignedScroll: Bool = false, @ViewBuilder content: @escaping () -> Content, destination: @escaping () -> Destination = { EmptyView() }) {
        self.title = title
        self.count = count
        self.spacing = spacing
        self.viewAlignedScroll = viewAlignedScroll
        self.content = content
        self.destination = destination
    }
    
    private var sectionHeader: some View {
        Group {
            if count > 10 {
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
        }
    }
    
    private var scrollView: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: spacing) {
                content()
            }
            .padding(.horizontal, 17)
            .padding(.top, 17)
            .scrollTargetLayout()
        }
        .scrollIndicators(.never)
        .padding(.top, -15)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            sectionHeader
            if viewAlignedScroll {
                scrollView.scrollTargetBehavior(.viewAligned)
            } else {
                scrollView
            }
        }
    }
}

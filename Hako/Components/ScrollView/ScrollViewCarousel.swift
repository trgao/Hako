//
//  ScrollViewCarousel.swift
//  Hako
//
//  Created by Gao Tianrun on 20/6/25.
//

import SwiftUI

struct ScrollViewCarousel<Content: View, Destination: View, Placeholder: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    private let title: String
    private let count: Int?
    private let viewAlignedScroll: Bool
    private let loadingState: LoadingEnum?
    private let refresh: () async -> Void
    private let placeholder: (Bool) -> Placeholder
    private let content: () -> Content
    private let destination: () -> Destination
    
    init(title: String, count: Int? = nil, viewAlignedScroll: Bool = false, loadingState: LoadingEnum? = nil, refresh: @escaping () async -> Void = {}, placeholder: @escaping (Bool) -> Placeholder = BigPlaceholderGridItem.init, @ViewBuilder content: @escaping () -> Content, destination: @escaping () -> Destination = { EmptyView() }) {
        self.title = title
        self.count = count
        self.viewAlignedScroll = viewAlignedScroll
        self.loadingState = loadingState
        self.refresh = refresh
        self.placeholder = placeholder
        self.content = content
        self.destination = destination
    }
    
    private var sectionHeader: some View {
        HStack {
            if let count = count, count > 10 && Destination.self != EmptyView.self {
                NavigationLink {
                    destination()
                } label: {
                    HStack {
                        Text(title)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color(.systemGray2))
                    }
                    .bold()
                }
                .buttonStyle(.plain)
            } else {
                Text(title).bold()
            }
            Spacer()
            if count == nil && loadingState == .error {
                Button {
                    Task {
                        await refresh()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            } else if count == 0 {
                Text("No \(title.lowercased().components(separatedBy: " ").last ?? title.lowercased())")
                    .font(.footnote)
                    .padding(8)
                    .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
                    .opacity(0.9)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 27)
        .font(.callout)
    }
    
    private var scrollView: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 10) {
                if (loadingState == .loading || loadingState == .error) && count == nil {
                    ForEach(Array(0..<10), id: \.self) { id in
                        placeholder(loadingState == .loading)
                    }
                } else {
                    content()
                }
            }
            .padding(.horizontal, 17)
            .padding(.top, (count ?? 0) > 10 ? 17 : 50)
            .scrollTargetLayout()
        }
        .scrollIndicators(.never)
        .padding(.top, (count ?? 0) > 10 ? -15 : -50)
        .disabled((loadingState == .loading || loadingState == .error) && count == nil)
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
        .padding(.vertical, 5)
    }
}

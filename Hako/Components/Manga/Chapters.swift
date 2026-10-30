//
//  Chapters.swift
//  Hako
//
//  Created by Gao Tianrun on 15/10/26.
//

import SwiftUI

struct Chapters: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.screenSize) private var screenSize
    @EnvironmentObject private var settings: SettingsManager
    @State private var chaptersPreview: [Chapter] = []
    private let id: Int
    private let chapters: [Chapter]?
    private let loadingState: LoadingEnum
    private let load: () async -> Void

    init(id: Int, chapters: [Chapter]?, loadingState: LoadingEnum, load: @escaping () async -> Void) {
        self.id = id
        self.chapters = chapters
        self.loadingState = loadingState
        self.load = load
    }

    var body: some View {
        ScrollViewCarousel(title: "Chapters", count: chapters?.count, item: Route.chapterList(ChapterList(id: id)), viewAlignedScroll: screenSize.width - 34 < 450, loadingState: loadingState, refresh: load) { isLoading in
            PlaceholderChapter(isLoading: isLoading)
        } content: {
            ForEach(chaptersPreview) { item in
                VStack(alignment: .leading) {
                    Text("\(item.title)")
                    HStack {
                        Spacer()
                        if let url = item.url {
                            Link(destination: URL(string: url)!) {
                                HStack {
                                    Image(systemName: "bubble.left.and.bubble.right.fill")
                                    if let comments = item.comments {
                                        Text("\(comments)")
                                    }
                                }
                                .foregroundStyle(settings.getAccentColor())
                                .font(.subheadline)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 3)
                }
                .frame(maxHeight: .infinity, alignment: .center)
                .padding(20)
                .frame(width: min(450, screenSize.width - 34), alignment: .center)
                .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
                .shadow(radius: 0.5)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .task {
            await load()
            chaptersPreview = Array(chapters?.prefix(10) ?? [])
        }
        .onChange(of: chapters?.count) {
            chaptersPreview = Array(chapters?.prefix(10) ?? [])
        }
    }
}

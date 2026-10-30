//
//  ChaptersListView.swift
//  Hako
//
//  Created by Gao Tianrun on 15/10/26.
//

import SwiftUI

struct ChaptersListView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller: ChaptersListViewController
    @State private var isRefresh = false
    private let id: Int

    init(id: Int) {
        self.id = id
        self._controller = StateObject(wrappedValue: ChaptersListViewController(id: id))
    }

    var body: some View {
        ZStack {
            if controller.loadingState == .error && controller.chapters.isEmpty {
                ErrorView(refresh: controller.refresh)
                    .padding(.vertical, 50)
            } else {
                List {
                    if controller.loadingState == .loading && controller.chapters.isEmpty {
                        LoadingList(showImage: false)
                    } else {
                        ForEach(controller.chapters) { chapter in
                            VStack(alignment: .leading) {
                                Text(chapter.title)
                                HStack {
                                    Spacer()
                                    if let url = chapter.url {
                                        Link(destination: URL(string: url)!) {
                                            HStack {
                                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                                if let comments = chapter.comments {
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
                            .onAppear {
                                Task {
                                    if chapter.id == controller.chapters.last?.id {
                                        await controller.loadMore()
                                    }
                                }
                            }
                        }
                        if controller.loadingState == .paginating {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                        }
                    }
                }
                .disabled(controller.loadingState == .loading && controller.chapters.isEmpty)
                .refreshable {
                    isRefresh = true
                }
                .task(id: isRefresh) {
                    if controller.chapters.isEmpty || isRefresh {
                        await controller.refresh()
                        isRefresh = false
                    }
                }
                if isRefresh {
                    LoadingView()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Chapters")
    }
}

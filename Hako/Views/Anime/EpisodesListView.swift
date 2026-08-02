//
//  EpisodesListView.swift
//  Hako
//
//  Created by Gao Tianrun on 7/7/26.
//

import SwiftUI

struct EpisodesListView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller: EpisodesListViewController
    @State private var isRefresh = false
    private let id: Int
    
    init(id: Int) {
        self.id = id
        self._controller = StateObject(wrappedValue: EpisodesListViewController(id: id))
    }
    
    var body: some View {
        ZStack {
            if controller.loadingState == .error && controller.episodes.isEmpty {
                ErrorView(refresh: controller.refresh)
                    .padding(.vertical, 50)
            } else {
                List {
                    if controller.loadingState == .loading && controller.episodes.isEmpty {
                        LoadingList(length: 20, showImage: false)
                    } else {
                        ForEach(controller.episodes) { episode in
                            NavigationLink {
                                EpisodeDetailsView(animeId: id, item: episode)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text("#\(episode.id): \(settings.getTitle(romaji: episode.titleRomanji, english: episode.title, native: episode.titleJapanese))")
                                    if let aired = episode.aired {
                                        Text("Aired on \(aired.toString())")
                                            .opacity(0.7)
                                            .font(.footnote)
                                    }
                                    Text("\(episode.score == nil ? "N/A" : "\(episode.score! * 2)") ⭐, \(episode.duration == nil || episode.duration == 0 ? "?" : "\(episode.duration! / 60)") mins")
                                        .opacity(0.7)
                                        .font(.footnote)
                                    HStack {
                                        if let recap = episode.recap, recap {
                                            TagItem(text: "Recap")
                                        }
                                        if let filler = episode.filler, filler {
                                            TagItem(text: "Filler")
                                        }
                                        Spacer()
                                        if let url = episode.forumUrl {
                                            Link(destination: URL(string: url)!) {
                                                HStack {
                                                    Image(systemName: "bubble.left.and.bubble.right.fill")
                                                    if let replies = episode.replies {
                                                        Text("\(replies)")
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
                            }
                            .buttonStyle(.plain)
                            .onAppear {
                                Task {
                                    if episode.id == controller.episodes.last?.id {
                                        await controller.loadMore()
                                    }
                                }
                            }
                        }
                        if controller.loadingState == .paginating {
                            LoadingList(length: 5, showImage: false)
                        }
                    }
                }
                .disabled(controller.loadingState == .loading && controller.episodes.isEmpty)
                .refreshable {
                    isRefresh = true
                }
                .task(id: isRefresh) {
                    if controller.episodes.isEmpty || isRefresh {
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
        .navigationTitle("Episodes")
    }
}

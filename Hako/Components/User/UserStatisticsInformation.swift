//
//  UserStatisticsInformation.swift
//  Hako
//
//  Created by Gao Tianrun on 14/3/26.
//

import SwiftUI

struct UserStatisticsInformation: View {
    @EnvironmentObject private var settings: SettingsManager
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.screenSize) private var screenSize
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private let userStatistics: UserStatistics?
    private let malAnimeStatistics: MALAnimeStatistics?
    private let loadingState: LoadingEnum

    init(userStatistics: UserStatistics?, loadingState: LoadingEnum) {
        self.userStatistics = userStatistics
        self.malAnimeStatistics = nil
        self.loadingState = loadingState
    }

    init(malAnimeStatistics: MALAnimeStatistics?, loadingState: LoadingEnum) {
        self.userStatistics = nil
        self.malAnimeStatistics = malAnimeStatistics
        self.loadingState = loadingState
    }

    @ViewBuilder private func StatisticsRow<T>(_ title: String, _ content: T?, _ icon: String, _ color: Color) -> some View {
        HStack {
            Label(title, systemImage: icon).labelStyle(.iconTint(color))
                .font(.footnote)
                .opacity(0.7)
            Spacer()
            if let content {
                Text(String(describing: content))
            } else {
                Text("example").skeleton(loadingState == .loading)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
        .contextMenu {
            if let content {
                Button {
                    UIPasteboard.general.string = String(describing: content)
                } label: {
                    Text("Copy")
                    Text(String(describing: content))
                }
            }
        }
    }

    @ViewBuilder private func StatisticsStatusRow(_ title: String, _ count: Int?, _ status: StatusEnum) -> some View {
        VStack {
            HStack {
                Label(title, systemImage: status.toIcon()).foregroundStyle(status.toColour())
                Spacer()
                if let count {
                    Text("\(count)").bold()
                } else {
                    Text("999")
                        .bold()
                        .skeleton(loadingState == .loading)
                }
            }
            if let count, let total = malAnimeStatistics?.numItems {
                ProgressView(value: Float(count) / Float(total))
                    .progressViewStyle(.thick)
                    .tint(status.toColour())
            } else {
                ProgressView(value: 0)
                    .progressViewStyle(.thick)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
        .contextMenu {
            if let count {
                Button {
                    UIPasteboard.general.string = String(describing: count)
                } label: {
                    Text("Copy")
                    Text(String(describing: count))
                }
            }
        }
    }

//    private var animeStatistics: some View {
//        ScrollViewSection(title: "Anime statistics") {
//            StatisticsRow("Days watched", userStatistics?.anime.daysWatched, "calendar", .blue)
//            StatisticsRow("Mean score", userStatistics?.anime.meanScore, "star.fill", .yellow)
//            StatisticsRow("Total entries", userStatistics?.anime.totalEntries, "circle.circle", .primary)
//            StatisticsRow("Watching", userStatistics?.anime.watching, "play.circle", .blue)
//            StatisticsRow("Completed", userStatistics?.anime.completed, "checkmark.circle", .green)
//            StatisticsRow("On hold", userStatistics?.anime.onHold, "pause.circle", .yellow)
//            StatisticsRow("Dropped", userStatistics?.anime.dropped, "minus.circle", .red)
//            StatisticsRow("Plan to watch", userStatistics?.anime.planToWatch, "plus.circle.dashed", .purple)
//            StatisticsRow("Episodes watched", userStatistics?.anime.episodesWatched, "video", .primary)
//        }
//    }
//
//    private var mangaStatistics: some View {
//        ScrollViewSection(title: "Manga statistics") {
//            StatisticsRow("Days read", userStatistics?.manga.daysRead, "calendar", .blue)
//            StatisticsRow("Mean score", userStatistics?.manga.meanScore, "star.fill", .yellow)
//            StatisticsRow("Total entries", userStatistics?.manga.totalEntries, "circle.circle", .primary)
//            StatisticsRow("Reading", userStatistics?.manga.reading, "book.circle", .blue)
//            StatisticsRow("Completed", userStatistics?.manga.completed, "checkmark.circle", .green)
//            StatisticsRow("On hold", userStatistics?.manga.onHold, "pause.circle", .yellow)
//            StatisticsRow("Dropped", userStatistics?.manga.dropped, "minus.circle", .red)
//            StatisticsRow("Plan to read", userStatistics?.manga.planToRead, "plus.circle.dashed", .purple)
//            StatisticsRow("Volumes read", userStatistics?.manga.volumesRead, "book.closed", .primary)
//            StatisticsRow("Chapters read", userStatistics?.manga.chaptersRead, "book.pages", .primary)
//        }
//    }

    @ViewBuilder private var malAnimeStatisticsSection: some View {
        VStack {
            Text("Anime statistics")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
            if dynamicTypeSize <= .xxLarge {
                HStack {
                    ScrollViewBox(title: "Days watched", image: "calendar", content: "\(malAnimeStatistics?.numDays, default: "")", isLoading: loadingState == .loading)
                    ScrollViewBox(title: "Mean score", image: "star.fill", content: "\(malAnimeStatistics?.meanScore, default: "")", isLoading: loadingState == .loading)
                }
                HStack {
                    ScrollViewBox(title: "Total entries", image: "circle.circle", content: "\(malAnimeStatistics?.numItems, default: "")", isLoading: loadingState == .loading)
                    ScrollViewBox(title: "Episodes watched", image: "video.fill", content: "\(malAnimeStatistics?.numEpisodes, default: "")", isLoading: loadingState == .loading)
                }
            }
            VStack(spacing: 0) {
                if dynamicTypeSize > .xxLarge {
                    StatisticsRow("Days watched", malAnimeStatistics?.numDays, "calendar", .blue)
                    StatisticsRow("Mean score", malAnimeStatistics?.meanScore, "star.fill", .yellow)
                    StatisticsRow("Total entries", malAnimeStatistics?.numItems, "circle.circle", .primary)
                    StatisticsRow("Episodes watched", malAnimeStatistics?.numEpisodes, "video", .primary)
                }
                StatisticsStatusRow("Watching", malAnimeStatistics?.numItemsWatching, .watching)
                StatisticsStatusRow("Completed", malAnimeStatistics?.numItemsCompleted, .completed)
                StatisticsStatusRow("On hold", malAnimeStatistics?.numItemsOnHold, .onHold)
                StatisticsStatusRow("Dropped", malAnimeStatistics?.numItemsDropped, .dropped)
                StatisticsStatusRow("Plan to watch", malAnimeStatistics?.numItemsPlanToWatch, .planToWatch)
            }
            .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 17)
    }

    var body: some View {
        // Temporary for anime statistics
        if !settings.hideUserAnimeStatistics {
            malAnimeStatisticsSection
        }

//        if userStatistics != nil {
//            if screenSize.width >= 1000 && dynamicTypeSize <= .xxxLarge {
//                HStack(alignment: .top) {
//                    if !settings.hideUserAnimeStatistics {
//                        animeStatistics
//                    }
//                    if !settings.hideUserMangaStatistics {
//                        mangaStatistics
//                    }
//                }
//            } else {
//                if !settings.hideUserAnimeStatistics {
//                    animeStatistics
//                }
//                if !settings.hideUserMangaStatistics {
//                    mangaStatistics
//                }
//            }
//        }
    }
}

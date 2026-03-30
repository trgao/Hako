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
    private let loadingState: LoadingEnum
    
    init(userStatistics: UserStatistics?, loadingState: LoadingEnum) {
        self.userStatistics = userStatistics
        self.loadingState = loadingState
    }
    
    @ViewBuilder private func StatisticsRow<T>(_ title: String, _ content: T?, _ icon: String, _ color: Color) -> some View {
        HStack {
            Label {
                Text(title)
                    .bold()
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                    .padding(.trailing, 10)
            }
            Spacer()
            if let content = content {
                Text(String(describing: content))
            } else {
                Text("example")
                    .skeleton(loadingState == .loading)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
        .contextMenu {
            if let content = content {
                Button {
                    UIPasteboard.general.string = String(describing: content)
                } label: {
                    Text("Copy")
                    Text(String(describing: content))
                }
            }
        }
    }
    
    private var animeStatistics: some View {
        ScrollViewSection(title: "Anime statistics") {
            StatisticsRow("Days watched", userStatistics?.anime.daysWatched, "calendar", .blue)
            StatisticsRow("Mean score", userStatistics?.anime.meanScore, "star.fill", .yellow)
            StatisticsRow("Total entries", userStatistics?.anime.totalEntries, "circle.circle", .primary)
            StatisticsRow("Watching", userStatistics?.anime.watching, "play.circle", .blue)
            StatisticsRow("Completed", userStatistics?.anime.completed, "checkmark.circle", .green)
            StatisticsRow("On hold", userStatistics?.anime.onHold, "pause.circle", .yellow)
            StatisticsRow("Plan to watch", userStatistics?.anime.planToWatch, "plus.circle.dashed", .purple)
            StatisticsRow("Episodes watched", userStatistics?.anime.episodesWatched, "video", .primary)
        }
    }
    
    private var mangaStatistics: some View {
        ScrollViewSection(title: "Manga statistics") {
            StatisticsRow("Days read", userStatistics?.manga.daysRead, "calendar", .blue)
            StatisticsRow("Mean score", userStatistics?.manga.meanScore, "star.fill", .yellow)
            StatisticsRow("Total entries", userStatistics?.manga.totalEntries, "circle.circle", .primary)
            StatisticsRow("Reading", userStatistics?.manga.reading, "book.circle", .blue)
            StatisticsRow("Completed", userStatistics?.manga.completed, "checkmark.circle", .green)
            StatisticsRow("On hold", userStatistics?.manga.onHold, "pause.circle", .yellow)
            StatisticsRow("Plan to read", userStatistics?.manga.planToRead, "plus.circle.dashed", .purple)
            StatisticsRow("Volumes read", userStatistics?.manga.volumesRead, "book.closed", .primary)
            StatisticsRow("Chapters read", userStatistics?.manga.chaptersRead, "book.pages", .primary)
        }
    }
    
    var body: some View {
        if screenSize.width >= 1000 && dynamicTypeSize <= .xxxLarge {
            HStack(alignment: .top) {
                if !settings.hideUserAnimeStatistics {
                    animeStatistics
                }
                if !settings.hideUserMangaStatistics {
                    mangaStatistics
                }
            }
        } else {
            if !settings.hideUserAnimeStatistics {
                animeStatistics
            }
            if !settings.hideUserMangaStatistics {
                mangaStatistics
            }
        }
    }
}

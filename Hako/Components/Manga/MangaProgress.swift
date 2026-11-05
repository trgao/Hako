//
//  MangaProgress.swift
//  Hako
//
//  Created by Gao Tianrun on 19/6/25.
//

import SwiftUI

struct MangaProgress: View {
    @EnvironmentObject private var settings: SettingsManager
    private let manga: Manga
    private let numChapters: String
    private let numVolumes: String
    private let isLoading: Bool
    private let networker = NetworkManager.shared

    private var listStatus: MyListStatus? {
        networker.getMangaListStatus(manga.id).value
    }

    private var numChaptersRead: Int {
        listStatus?.numChaptersRead ?? 0
    }

    private var numVolumesRead: Int {
        listStatus?.numVolumesRead ?? 0
    }

    private var chaptersReadProgress: Float {
        if let chapters = manga.numChapters, chapters > 0 {
            return Float(numChaptersRead) / Float(chapters)
        }
        return numChaptersRead == 0 ? 0 : 0.5
    }

    private var volumesReadProgress: Float {
        if let volumes = manga.numVolumes, volumes > 0 {
            return Float(numVolumesRead) / Float(volumes)
        }
        return numVolumesRead == 0 ? 0 : 0.5
    }

    init(manga: Manga, isLoading: Bool) {
        self.manga = manga
        self.isLoading = isLoading
        if let numChapters = manga.numChapters, numChapters > 0 {
            self.numChapters = String(numChapters)
        } else {
            self.numChapters = "?"
        }
        if let numVolumes = manga.numVolumes, numVolumes > 0 {
            self.numVolumes = String(numVolumes)
        } else {
            self.numVolumes = "?"
        }
    }

    var body: some View {
        ScrollViewSection(title: "Progress") {
            VStack {
                if isLoading {
                    HStack {
                        Text("Placeholder")
                            .bold()
                        Spacer()
                        Text("0 / 0  0 / 0")
                    }
                    .skeleton()
                    ProgressView(value: 0)
                        .skeleton()
                } else if let status = listStatus?.status {
                    HStack {
                        Text(status.toString())
                            .foregroundStyle(status.toColour())
                            .bold()
                        Spacer()
                        Label("\(numVolumesRead) / \(numVolumes)", systemImage: "book.closed.fill")
                            .labelStyle(.reducedSpace)
                        Label("\(numChaptersRead) / \(numChapters)", systemImage: "book.pages.fill")
                            .labelStyle(.reducedSpace)
                    }
                    if settings.mangaReadProgress == 0 {
                        ProgressView(value: chaptersReadProgress)
                            .tint(status.toColour())
                    } else {
                        ProgressView(value: volumesReadProgress)
                            .tint(status.toColour())
                    }
                } else {
                    HStack {
                        Text("Not added")
                            .bold()
                        Spacer()
                        Label("0 / \(numVolumes)", systemImage: "book.closed.fill")
                            .labelStyle(.reducedSpace)
                        Label("0 / \(numChapters)", systemImage: "book.pages.fill")
                            .labelStyle(.reducedSpace)
                    }
                    ProgressView(value: 0)
                }
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
        }
    }
}

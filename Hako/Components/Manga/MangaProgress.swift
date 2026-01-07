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
    private let numChaptersRead: String
    private let chaptersReadProgress: Float
    private let numVolumes: String
    private let numVolumesRead: String
    private let volumesReadProgress: Float
    private let isLoading: Bool
    
    init(manga: Manga, isLoading: Bool) {
        self.manga = manga
        self.isLoading = isLoading
        let numChaptersRead = manga.myListStatus?.numChaptersRead ?? 0
        let numVolumesRead = manga.myListStatus?.numVolumesRead ?? 0
        if let numChapters = manga.numChapters, numChapters > 0 {
            self.numChapters = String(numChapters)
            self.chaptersReadProgress = Float(numChaptersRead) / Float(numChapters)
        } else {
            self.numChapters = "?"
            self.chaptersReadProgress = numChaptersRead == 0 ? 0 : 0.5
        }
        if let numVolumes = manga.numVolumes, numVolumes > 0 {
            self.numVolumes = String(numVolumes)
            self.volumesReadProgress = Float(numVolumesRead) / Float(numVolumes)
        } else {
            self.numVolumes = "?"
            self.volumesReadProgress = numVolumesRead == 0 ? 0 : 0.5
        }
        self.numChaptersRead = String(numChaptersRead)
        self.numVolumesRead = String(numVolumesRead)
    }
    
    var body: some View {
        ScrollViewSection(title: "Progress") {
            VStack {
                if isLoading {
                    ProgressView(value: 0)
                        .skeleton()
                    HStack {
                        Text("Placeholder")
                            .bold()
                        Spacer()
                        Text("0 / 0  0 / 0")
                    }
                    .skeleton()
                } else if let status = manga.myListStatus?.status {
                    if settings.mangaReadProgress == 0 {
                        ProgressView(value: chaptersReadProgress)
                            .tint(status.toColour())
                    } else {
                        ProgressView(value: volumesReadProgress)
                            .tint(status.toColour())
                    }
                    HStack {
                        Text(status.toString())
                            .bold()
                        Spacer()
                        Label("\(numVolumesRead) / \(numVolumes)", systemImage: "book.closed.fill")
                            .labelStyle(CustomLabel(spacing: 2))
                        Label("\(numChaptersRead) / \(numChapters)", systemImage: "book.pages.fill")
                            .labelStyle(CustomLabel(spacing: 2))
                    }
                } else {
                    ProgressView(value: 0)
                    HStack {
                        Text("Not added")
                            .bold()
                        Spacer()
                        Label("0 / \(numVolumes)", systemImage: "book.closed.fill")
                            .labelStyle(CustomLabel(spacing: 2))
                        Label("0 / \(numChapters)", systemImage: "book.pages.fill")
                            .labelStyle(CustomLabel(spacing: 2))
                    }
                }
            }
            .padding(20)
        }
    }
}

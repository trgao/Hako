//
//  MangaListItem.swift
//  Hako
//
//  Created by Gao Tianrun on 11/5/25.
//

import SwiftUI

struct MangaListItem: View {
    @EnvironmentObject private var settings: SettingsManager
    @Binding private var selectedManga: MALListManga?
    @Binding private var selectedMangaIndex: Int?
    private let manga: MALListManga
    private let colours: [StatusEnum:Color] = [
        .reading: Color(.systemGreen),
        .completed: Color(.systemBlue),
        .onHold: Color(.systemYellow),
        .dropped: Color(.systemRed),
        .planToRead: .primary,
        .none: Color(.systemGray)
    ]
    private let index: Int
    let networker = NetworkManager.shared
    
    init(manga: MALListManga) {
        self.manga = manga
        self._selectedManga = .constant(nil)
        self._selectedMangaIndex = .constant(nil)
        self.index = 0
    }
    
    init(manga: MALListManga, status: StatusEnum, selectedManga: Binding<MALListManga?>, selectedMangaIndex: Binding<Int?>, index: Int) {
        self.manga = manga
        self._selectedManga = selectedManga
        self._selectedMangaIndex = selectedMangaIndex
        self.index = index
    }
    
    var body: some View {
        NavigationLink {
            MangaDetailsView(id: manga.id)
        } label: {
            HStack {
                ImageFrame(id: "manga\(manga.id)", imageUrl: manga.node.mainPicture?.large, imageSize: .small)
                VStack(alignment: .leading) {
                    Text(manga.node.title)
                        .lineLimit(settings.getLineLimit())
                        .bold()
                        .font(.system(size: 16))
                    if let numChaptersRead = manga.listStatus?.numChaptersRead, let numVolumesRead = manga.listStatus?.numVolumesRead {
                        if settings.useChapterProgress {
                            if let numChapters = manga.node.numChapters, numChapters > 0 {
                                VStack(alignment: .leading) {
                                    ProgressView(value: Float(numChaptersRead) / Float(numChapters))
                                        .tint(colours[manga.listStatus?.status ?? .none])
                                    HStack {
                                        if let numVolumes = manga.node.numVolumes, numVolumes > 0 {
                                            Label("\(String(numVolumesRead)) / \(String(numVolumes))", systemImage: "book.closed.fill")
                                                .font(.system(size: 13))
                                                .foregroundStyle(Color(.systemGray))
                                                .labelStyle(CustomLabel(spacing: 2))
                                        } else {
                                            Label("\(String(numVolumesRead)) / ?", systemImage: "book.closed.fill")
                                                .font(.system(size: 13))
                                                .foregroundStyle(Color(.systemGray))
                                                .labelStyle(CustomLabel(spacing: 2))
                                        }
                                        Label("\(String(numChaptersRead)) / \(String(numChapters))", systemImage: "book.pages.fill")
                                            .font(.system(size: 13))
                                            .foregroundStyle(Color(.systemGray))
                                            .labelStyle(CustomLabel(spacing: 2))
                                    }
                                }
                            } else {
                                VStack(alignment: .leading) {
                                    ProgressView(value: numChaptersRead == 0 ? 0 : 0.5)
                                        .tint(colours[manga.listStatus?.status ?? .none])
                                    HStack {
                                        if let numVolumes = manga.node.numVolumes, numVolumes > 0 {
                                            Label("\(String(numVolumesRead)) / \(String(numVolumes))", systemImage: "book.closed.fill")
                                                .font(.system(size: 13))
                                                .foregroundStyle(Color(.systemGray))
                                                .labelStyle(CustomLabel(spacing: 2))
                                        } else {
                                            Label("\(String(numVolumesRead)) / ?", systemImage: "book.closed.fill")
                                                .font(.system(size: 13))
                                                .foregroundStyle(Color(.systemGray))
                                                .labelStyle(CustomLabel(spacing: 2))
                                        }
                                        Label("\(String(numChaptersRead)) / ?", systemImage: "book.pages.fill")
                                            .font(.system(size: 13))
                                            .foregroundStyle(Color(.systemGray))
                                            .labelStyle(CustomLabel(spacing: 2))
                                    }
                                }
                            }
                        } else {
                            if let numVolumes = manga.node.numVolumes, numVolumes > 0 {
                                VStack(alignment: .leading) {
                                    ProgressView(value: Float(numVolumesRead) / Float(numVolumes))
                                        .tint(colours[manga.listStatus?.status ?? .none])
                                    HStack {
                                        Label("\(String(numVolumesRead)) / \(String(numVolumes))", systemImage: "book.closed.fill")
                                            .font(.system(size: 13))
                                            .foregroundStyle(Color(.systemGray))
                                            .labelStyle(CustomLabel(spacing: 2))
                                        if let numChapters = manga.node.numChapters, numChapters > 0 {
                                            Label("\(String(numChaptersRead)) / \(String(numChapters))", systemImage: "book.pages.fill")
                                                .font(.system(size: 13))
                                                .foregroundStyle(Color(.systemGray))
                                                .labelStyle(CustomLabel(spacing: 2))
                                        } else {
                                            Label("\(String(numChaptersRead)) / ?", systemImage: "book.pages.fill")
                                                .font(.system(size: 13))
                                                .foregroundStyle(Color(.systemGray))
                                                .labelStyle(CustomLabel(spacing: 2))
                                        }
                                    }
                                }
                            } else {
                                VStack(alignment: .leading) {
                                    ProgressView(value: numVolumesRead == 0 ? 0 : 0.5)
                                        .tint(colours[manga.listStatus?.status ?? .none])
                                    HStack {
                                        Label("\(String(numVolumesRead)) / ?", systemImage: "book.closed.fill")
                                            .font(.system(size: 13))
                                            .foregroundStyle(Color(.systemGray))
                                            .labelStyle(CustomLabel(spacing: 2))
                                        if let numChapters = manga.node.numChapters, numChapters > 0 {
                                            Label("\(String(numChaptersRead)) / \(String(numChapters))", systemImage: "book.pages.fill")
                                                .font(.system(size: 13))
                                                .foregroundStyle(Color(.systemGray))
                                                .labelStyle(CustomLabel(spacing: 2))
                                        } else {
                                            Label("\(String(numChaptersRead)) / ?", systemImage: "book.pages.fill")
                                                .font(.system(size: 13))
                                                .foregroundStyle(Color(.systemGray))
                                                .labelStyle(CustomLabel(spacing: 2))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(manga.node.status?.formatStatus() ?? "")
                                .opacity(0.7)
                                .font(.system(size: 12))
                            if let score = manga.listStatus?.score, score > 0 {
                                Text("\(score) ⭐")
                                    .bold()
                                    .font(.system(size: 13))
                            }
                        }
                        Spacer()
                        if networker.isSignedIn && manga.listStatus != nil {
                            Button {
                                selectedManga = manga
                                selectedMangaIndex = index
                            } label: {
                                Image(systemName: "square.and.pencil")
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                .padding(5)
            }
        }
        .padding(5)
    }
}

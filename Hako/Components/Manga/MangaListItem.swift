//
//  MangaListItem.swift
//  Hako
//
//  Created by Gao Tianrun on 11/5/25.
//

import SwiftUI

struct MangaListItem: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var networker = NetworkManager.shared
    @Binding private var selectedManga: MALListManga?
    @Binding private var selectedMangaIndex: Int?
    private let manga: MALListManga
    private let index: Int
    private let numChapters: String
    private let numChaptersRead: String
    private let chaptersReadProgress: Float
    private let numVolumes: String
    private let numVolumesRead: String
    private let volumesReadProgress: Float
    
    init(manga: MALListManga, selectedManga: Binding<MALListManga?> = Binding.constant(nil), selectedMangaIndex: Binding<Int?> = Binding.constant(nil), index: Int = -1) {
        self.manga = manga
        self._selectedManga = selectedManga
        self._selectedMangaIndex = selectedMangaIndex
        self.index = index
        let chaptersRead = manga.listStatus?.numChaptersRead ?? 0
        let volumesRead = manga.listStatus?.numVolumesRead ?? 0
        if let chapters = manga.node.numChapters, chapters > 0 {
            self.numChapters = String(chapters)
            self.chaptersReadProgress = Float(chaptersRead) / Float(chapters)
        } else {
            self.numChapters = "?"
            self.chaptersReadProgress = chaptersRead == 0 ? 0 : 0.5
        }
        if let volumes = manga.node.numVolumes, volumes > 0 {
            self.numVolumes = String(volumes)
            self.volumesReadProgress = Float(volumesRead) / Float(volumes)
        } else {
            self.numVolumes = "?"
            self.volumesReadProgress = volumesRead == 0 ? 0 : 0.5
        }
        self.numChaptersRead = String(chaptersRead)
        self.numVolumesRead = String(volumesRead)
    }
    
    var body: some View {
        NavigationLink {
            MangaDetailsView(manga: manga.node)
        } label: {
            HStack {
                ImageFrame(id: "manga\(manga.id)", imageUrl: manga.node.mainPicture?.large, imageSize: Constants.listImageSize)
                VStack(alignment: .leading) {
                    if let title = manga.node.alternativeTitles?.en, !title.isEmpty && settings.preferredTitleLanguage == 1 {
                        Text(title)
                            .lineLimit(settings.getLineLimit())
                            .bold()
                            .font(.callout)
                    } else {
                        Text(manga.node.title)
                            .lineLimit(settings.getLineLimit())
                            .bold()
                            .font(.callout)
                    }
                    if networker.isSignedIn || manga.listStatus != nil {
                        VStack(alignment: .leading) {
                            ProgressView(value: settings.mangaReadProgress == 0 ? chaptersReadProgress : volumesReadProgress)
                                .tint(manga.listStatus?.status?.toColour())
                            HStack {
                                Label("\(numVolumesRead) / \(numVolumes)", systemImage: "book.closed.fill")
                                    .foregroundStyle(Color(.systemGray))
                                    .labelStyle(CustomLabelStyle())
                                Label("\(numChaptersRead) / \(numChapters)", systemImage: "book.pages.fill")
                                    .foregroundStyle(Color(.systemGray))
                                    .labelStyle(CustomLabelStyle())
                                Spacer()
                                if let score = manga.listStatus?.score, score > 0 {
                                    Text("\(score) ⭐")
                                        .bold()
                                }
                            }
                            .font(.footnote)
                        }
                    }
                    HStack(alignment: .top) {
                        if let status = manga.node.status {
                            Text(status.formatStatus())
                                .opacity(0.7)
                                .font(.footnote)
                                .padding(.top, 1)
                        }
                        Spacer()
                        if networker.isSignedIn && index != -1 {
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
            .contextMenu {
                ShareLink(item: URL(string: "https://myanimelist.net/manga/\(manga.id)")!) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
        .padding(5)
    }
}

//
//  MangaListItem.swift
//  Hako
//
//  Created by Gao Tianrun on 11/5/25.
//

import SwiftUI

struct MangaListItem: View {
    @EnvironmentObject private var settings: SettingsManager
    @ObservedObject private var networker = NetworkManager.shared
    @Binding private var selectedManga: MALListManga?
    private let manga: MALListManga
    private let numChapters: String
    private let numVolumes: String
    private let isLoading: Bool
    private let isOtherUser: Bool

    private var title: String {
        settings.getTitle(romaji: manga.node.title, english: manga.node.alternativeTitles?.en, native: manga.node.alternativeTitles?.ja)
    }

    private var listStatus: MyListStatus? {
        isOtherUser ? manga.listStatus : networker.getMangaListStatus(manga.id).value
    }

    private var numChaptersRead: Int {
        listStatus?.numChaptersRead ?? 0
    }

    private var numVolumesRead: Int {
        listStatus?.numVolumesRead ?? 0
    }

    private var chaptersReadProgress: Float {
        if let chapters = manga.node.numChapters, chapters > 0 {
            return Float(numChaptersRead) / Float(chapters)
        }
        return numChaptersRead == 0 ? 0 : 0.5
    }

    private var volumesReadProgress: Float {
        if let volumes = manga.node.numVolumes, volumes > 0 {
            return Float(numVolumesRead) / Float(volumes)
        }
        return numVolumesRead == 0 ? 0 : 0.5
    }

    init(manga: MALListManga, isLoading: Bool = false, isOtherUser: Bool = false, selectedManga: Binding<MALListManga?> = .constant(nil)) {
        self.manga = manga
        self.isLoading = isLoading
        self.isOtherUser = isOtherUser
        self._selectedManga = selectedManga

        if let chapters = manga.node.numChapters, chapters > 0 {
            self.numChapters = String(chapters)
        } else {
            self.numChapters = "?"
        }
        if let volumes = manga.node.numVolumes, volumes > 0 {
            self.numVolumes = String(volumes)
        } else {
            self.numVolumes = "?"
        }
    }

    var body: some View {
        NavigationLink(value: Route.mangaItem(manga)) {
            HStack {
                ImageFrame(id: "manga\(manga.id)", imageUrl: manga.node.mainPicture?.large, imageSize: Constants.listImageSize)
                VStack(alignment: .leading) {
                    Text(title)
                        .lineLimit(settings.getLineLimit())
                        .bold()
                        .foregroundStyle(Color.primary)
                    HStack(alignment: .center) {
                        VStack(alignment: .leading) {
                            if let mediaType = manga.node.mediaType {
                                Text(mediaType.formatMediaType())
                            }
                            if let status = manga.node.status {
                                Text(status.formatStatus())
                            }
                            HStack {
                                Text("\(manga.node.mean == nil ? "N/A" : String(manga.node.mean!)) ⭐")
                                if let score = listStatus?.score, score > 0 {
                                    Label("\(score) ⭐", systemImage: "person.fill")
                                        .labelStyle(.reducedSpace)
                                }
                            }
                            .bold()
                        }
                        .opacity(0.7)
                        .font(.footnote)
                        .foregroundStyle(Color.primary)
                        Spacer()
                        if networker.isSignedIn && !isOtherUser {
                            Button {
                                selectedManga = manga
                            } label: {
                                Image(systemName: "square.and.pencil")
                            }
                            .buttonStyle(.bordered)
                            .disabled(isLoading)
                        }
                    }
                    if networker.isSignedIn || listStatus != nil {
                        VStack(alignment: .leading) {
                            ProgressView(value: settings.mangaReadProgress == 0 ? chaptersReadProgress : volumesReadProgress)
                                .tint(listStatus?.status?.toColour())
                            HStack {
                                Label("\(numVolumesRead) / \(numVolumes)", systemImage: "book.closed.fill")
                                    .foregroundStyle(Color(.systemGray))
                                    .labelStyle(.reducedSpace)
                                Label("\(numChaptersRead) / \(numChapters)", systemImage: "book.pages.fill")
                                    .foregroundStyle(Color(.systemGray))
                                    .labelStyle(.reducedSpace)
                            }
                            .font(.footnote)
                        }
                        .padding(.top, 5)
                    }
                }
                .padding(.horizontal, 5)
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

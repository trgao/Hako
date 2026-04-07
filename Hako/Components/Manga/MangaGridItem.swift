//
//  MangaGridItem.swift
//  Hako
//
//  Created by Gao Tianrun on 11/5/25.
//

import SwiftUI

struct MangaGridItem: View {
    @Environment(\.screenRatio) private var screenRatio
    @EnvironmentObject private var settings: SettingsManager
    private let id: Int
    private let title: String?
    private let enTitle: String?
    private let jaTitle: String?
    private let imageUrl: String?
    private let subtitle: String?
    private let manga: Manga
    private let isRecentlyViewed: Bool
    private var itemTitle: String {
        settings.getTitle(romaji: title, english: enTitle, native: jaTitle)
    }
    
    init(id: Int, title: String?, enTitle: String?, jaTitle: String?, imageUrl: String?, subtitle: String? = nil, manga: Manga? = nil, isRecentlyViewed: Bool = false) {
        self.id = id
        self.title = title
        self.enTitle = enTitle
        self.jaTitle = jaTitle
        self.imageUrl = imageUrl
        self.subtitle = subtitle
        self.manga = manga ?? Manga(id: id, title: title ?? "", enTitle: enTitle, jaTitle: jaTitle, imageUrl: imageUrl)
        self.isRecentlyViewed = isRecentlyViewed
    }
    
    var body: some View {
        ZoomTransition {
            MangaDetailsView(manga: manga)
        } label: {
            VStack {
                ImageFrame(id: "manga\(id)", imageUrl: imageUrl, imageSize: .large)
                    .overlay {
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .bold()
                                .font(.subheadline)
                                .foregroundStyle(.white)
                                .padding(10)
                                .background {
                                    Color.black.opacity(0.4)
                                        .blur(radius: 8, opaque: false)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
                    .contextMenu {
                        if let mean = manga.mean {
                            Label("\(String(mean))", systemImage: "star.fill")
                        }
                        if let mediaType = manga.mediaType {
                            Label(mediaType.formatMediaType(), systemImage: Constants.mediaTypeIcons[mediaType] ?? "book.fill")
                        }
                        if let status = manga.status {
                            Label(status.formatStatus(), systemImage: "info.circle")
                        }
                        ShareLink(item: URL(string: "https://myanimelist.net/manga/\(id)")!) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        if isRecentlyViewed {
                            Button {
                                settings.recentlyViewedItems = settings.recentlyViewedItems.filter { $0.id != "manga\(id)" }
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                Text(itemTitle)
                    .lineLimit(settings.getLineLimit())
                    .frame(width: 150 * screenRatio, alignment: .leading)
                    .padding(5)
                    .font(.callout)
            }
        }
        .padding(5)
    }
}


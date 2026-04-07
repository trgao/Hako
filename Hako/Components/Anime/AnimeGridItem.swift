//
//  AnimeGridItem.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

struct AnimeGridItem: View {
    @Environment(\.screenRatio) private var screenRatio
    @EnvironmentObject private var settings: SettingsManager
    private let id: Int
    private let title: String?
    private let enTitle: String?
    private let jaTitle: String?
    private let imageUrl: String?
    private let subtitle: String?
    private let anime: Anime
    private let isRecentlyViewed: Bool
    private var itemTitle: String {
        settings.getTitle(romaji: title, english: enTitle, native: jaTitle)
    }
    
    init(id: Int, title: String?, enTitle: String?, jaTitle: String?, imageUrl: String?, subtitle: String? = nil, anime: Anime? = nil, isRecentlyViewed: Bool = false) {
        self.id = id
        self.title = title
        self.enTitle = enTitle
        self.jaTitle = jaTitle
        self.imageUrl = imageUrl
        self.subtitle = subtitle
        self.anime = anime ?? Anime(id: id, title: title ?? "", enTitle: enTitle, jaTitle: jaTitle, imageUrl: imageUrl)
        self.isRecentlyViewed = isRecentlyViewed
    }
    
    var body: some View {
        ZoomTransition {
            AnimeDetailsView(anime: anime)
        } label: {
            VStack {
                ImageFrame(id: "anime\(id)", imageUrl: imageUrl, imageSize: .large)
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
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                    .contextMenu {
                        if let mean = anime.mean {
                            Label("\(String(mean))", systemImage: "star.fill")
                        }
                        if let mediaType = anime.mediaType {
                            Label(mediaType.formatMediaType(), systemImage: Constants.mediaTypeIcons[mediaType] ?? "tv.fill")
                        }
                        if let startSeason = anime.startSeason, let season = startSeason.season, let year = startSeason.year {
                            Label("\(season.rawValue.capitalized), \(String(year))", systemImage: "calendar")
                        }
                        if let status = anime.status {
                            Label(status.formatStatus(), systemImage: "info.circle")
                        }
                        ShareLink(item: URL(string: "https://myanimelist.net/anime/\(id)")!) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        if isRecentlyViewed {
                            Button {
                                settings.recentlyViewedItems = settings.recentlyViewedItems.filter { $0.id != "anime\(id)" }
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

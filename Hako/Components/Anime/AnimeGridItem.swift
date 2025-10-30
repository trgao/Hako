//
//  AnimeGridItem.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

struct AnimeGridItem: View {
    @EnvironmentObject private var settings: SettingsManager
    private let id: Int
    private let title: String?
    private let enTitle: String?
    private let imageUrl: String?
    private let subtitle: String?
    private let anime: Anime
    
    init(id: Int, title: String?, enTitle: String?, imageUrl: String?, subtitle: String? = nil, anime: Anime? = nil) {
        self.id = id
        self.title = title
        self.enTitle = enTitle
        self.imageUrl = imageUrl
        self.subtitle = subtitle
        self.anime = anime ?? Anime(id: id, title: title ?? "", enTitle: enTitle)
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
                                .font(.system(size: 16))
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
                        if let mean = anime.mean {
                            Label("\(String(mean))", systemImage: "star.fill")
                        }
                        if let startSeason = anime.startSeason, let season = startSeason.season, let year = startSeason.year {
                            Label("\(season.capitalized), \(String(year))", systemImage: "calendar")
                        }
                        if let mediaType = anime.mediaType, let status = anime.status {
                            Label("\(mediaType.formatMediaType()) ・ \(status.formatStatus())", systemImage: "info.circle")
                        }
                        ShareLink(item: URL(string: "https://myanimelist.net/anime/\(id)")!) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }
                if let title = enTitle, !title.isEmpty && settings.preferredTitleLanguage == 1 {
                    Text(title)
                        .lineLimit(settings.getLineLimit())
                        .frame(width: 150, alignment: .leading)
                        .padding(5)
                        .font(.system(size: 16))
                        .tint(.primary)
                } else {
                    Text(title ?? "")
                        .lineLimit(settings.getLineLimit())
                        .frame(width: 150, alignment: .leading)
                        .padding(5)
                        .font(.system(size: 16))
                        .tint(.primary)
                }
            }
        }
        .padding(5)
    }
}

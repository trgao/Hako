//
//  AiringScheduleItem.swift
//  Hako
//
//  Created by Gao Tianrun on 4/4/26.
//

import SwiftUI

struct AiringScheduleItem: View {
    @Environment(\.screenSize) private var screenSize
    @EnvironmentObject private var settings: SettingsManager
    private let item: AiringSchedule
    private var title: String {
        if let title = item.media.title.english, !title.isEmpty && settings.preferredTitleLanguage == 1 {
            return title
        } else {
            return item.media.title.romaji ?? ""
        }
    }
    
    init(item: AiringSchedule) {
        self.item = item
    }
    
    var body: some View {
        if let id = item.media.idMal {
            ZoomTransition {
                AnimeDetailsView(anime: Anime(id: id, title: item.media.title.romaji ?? "", enTitle: item.media.title.english, jaTitle: item.media.title.native, imageUrl: item.media.coverImage?.large))
            } label: {
                HStack {
                    ImageFrame(id: "anime\(id)", imageUrl: item.media.coverImage?.large, imageSize: Constants.listImageSize)
                    VStack(alignment: .leading) {
                        Text(title)
                            .lineLimit(settings.getLineLimit())
                            .bold()
                        VStack(alignment: .leading) {
                            if let season = item.media.season, let year = item.media.seasonYear {
                                Text("\(season.lowercased().capitalized), \(String(year))")
                            }
                            if let status = item.media.status {
                                Text(status.formatStatus())
                            }
                        }
                        .opacity(0.7)
                        .font(.footnote)
                        .padding(.vertical, 3)
                        Label("Episode \(String(item.episode)) airing at \(Date(timeIntervalSince1970: TimeInterval(item.airingAt)).formatted(.dateTime.hour().minute()))", systemImage: "alarm.fill")
                            .labelStyle(.iconTint(settings.getAccentColor()))
                            .opacity(0.7)
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 5)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .contextMenu {
                    ShareLink(item: URL(string: "https://myanimelist.net/anime/\(id)")!) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}

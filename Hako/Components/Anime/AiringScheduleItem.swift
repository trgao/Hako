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
    private let isAiringNext: Bool
    private var title: String {
        settings.getTitle(romaji: item.media.title?.romaji, english: item.media.title?.english, native: item.media.title?.native)
    }
    
    init(item: AiringSchedule, isAiringNext: Bool) {
        self.item = item
        self.isAiringNext = isAiringNext
    }
    
    var body: some View {
        if let id = item.media.idMal {
            ZoomTransition {
                AnimeDetailsView(anime: Anime(id: id, title: item.media.title?.romaji ?? "", enTitle: item.media.title?.english, jaTitle: item.media.title?.native, imageUrl: item.media.coverImage?.large))
            } label: {
                HStack {
                    ImageFrame(id: "anime\(id)", imageUrl: item.media.coverImage?.large, imageSize: Constants.listImageSize)
                    VStack(alignment: .leading) {
                        Text(title)
                            .lineLimit(settings.getLineLimit())
                            .bold()
                        let currentTime = Int(Date().timeIntervalSince1970)
                        if isAiringNext {
                            TagItem(text: "Airing next", systemImage: "forward.fill")
                        } else if item.airingAt <= currentTime && item.airingAt + (item.media.duration ?? 0) * 60 >= currentTime {
                            TagItem(text: "Airing now", systemImage: "play.fill")
                        }
                        if let season = item.media.season, let year = item.media.seasonYear {
                            Text("\(season.lowercased().capitalized), \(String(year))")
                                .opacity(0.7)
                                .font(.footnote)
                                .padding(.top, 2)
                        }
                        Label("Episode \(String(item.episode)) \(item.airingAt > currentTime ? "airing" : "aired") at \(Date(timeIntervalSince1970: TimeInterval(item.airingAt)).toTimeString())", systemImage: "alarm.fill")
                            .foregroundStyle(settings.getAccentColor())
                            .bold()
                            .font(.footnote)
                            .padding(.top, 2)
                    }
                    .padding(.horizontal, 5)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(15)
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

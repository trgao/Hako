//
//  EpisodeItem.swift
//  Hako
//
//  Created by Gao Tianrun on 7/7/26.
//

import SwiftUI

struct EpisodeItem: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.screenSize) private var screenSize
    @EnvironmentObject private var settings: SettingsManager
    private let item: Episode
    private var title: String {
        let title = settings.getTitle(romaji: item.titleRomanji, english: item.title, native: item.titleJapanese)
        return title.isEmpty ? "Episode \(item.id)" : title
    }
    
    init(item: Episode) {
        self.item = item
    }
    
    var body: some View {
        NavigationLink {
            EpisodeDetailsView(item: item)
        } label: {
            VStack(alignment: .leading) {
                Text("\(item.id). \(title)")
                if let aired = item.aired {
                    Text("Aired on \(aired.toString())")
                        .opacity(0.7)
                        .font(.footnote)
                }
                Text("\(item.duration == nil || item.duration == 0 ? "?" : "\(item.duration! / 60)") mins")
                    .opacity(0.7)
                    .font(.footnote)
                HStack {
                    if let recap = item.recap, recap {
                        TagItem(text: "Recap")
                    }
                    if let filler = item.filler, filler {
                        TagItem(text: "Filler")
                    }
                    Spacer()
                    if let url = item.forumUrl {
                        Link(destination: URL(string: url)!) {
                            HStack {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                if let replies = item.replies {
                                    Text("\(replies)")
                                }
                            }
                            .foregroundStyle(settings.getAccentColor())
                            .font(.subheadline)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 3)
            }
            .frame(maxHeight: .infinity, alignment: .center)
            .padding(20)
            .frame(width: min(450, screenSize.width - 34), alignment: .center)
            .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
            .shadow(radius: 0.5)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

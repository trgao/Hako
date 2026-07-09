//
//  EpisodeDetailsView.swift
//  Hako
//
//  Created by Gao Tianrun on 8/7/26.
//

import SwiftUI

struct EpisodeDetailsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var settings: SettingsManager
    @State private var showTranslation = false
    private let item: Episode
    private var title: String {
        let title = settings.getTitle(romaji: item.titleRomanji, english: item.title, native: item.titleJapanese)
        return title.isEmpty ? "Episode \(item.id)" : title
    }
    
    init(item: Episode) {
        self.item = item
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text(title).bold()
                    Group {
                        if settings.preferredTitleLanguage == 2 {
                            if !item.title.isEmpty && item.title != title {
                                Text(item.title)
                            } else if let title = item.titleRomanji {
                                Text(title)
                            }
                        } else if let native = item.titleJapanese, !native.isEmpty && settings.preferredTitleLanguage != 2 {
                            Text(native)
                        }
                    }
                    .opacity(0.7)
                    Group {
                        if let aired = item.aired {
                            Text("Aired on \(aired.toString())")
                        }
                        Text("Polled \(item.score == nil ? "?" : "\(item.score!)") / 5, \(item.duration == nil || item.duration == 0 ? "?" : "\(item.duration! / 60)") mins")
                    }
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
                    .padding(3)
                }
                .padding(.horizontal, 5)
                if let synopsis = item.synopsis {
                    Text(synopsis)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
                        .shadow(radius: 0.5)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
                        .contextMenu {
                            Button {
                                UIPasteboard.general.string = synopsis
                            } label: {
                                Label("Copy", systemImage: "document.on.document")
                            }
                            if !ProcessInfo.processInfo.isMacCatalystApp {
                                Button {
                                    showTranslation = true
                                } label: {
                                    Label("Translate", systemImage: "translate")
                                }
                            }
                        }
                        .translationPresentation(isPresented: $showTranslation,
                                                 text: synopsis)
                }
            }
            .padding(17)
        }
        .background(colorScheme == .light ? Color(.systemGray6) : .black)
        .toolbar {
            if let url = item.url {
                ShareLink(item: URL(string: url)!) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Episode \(item.id)")
    }
}

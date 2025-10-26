//
//  ThemeSongs.swift
//  Hako
//
//  Created by Gao Tianrun on 13/5/25.
//

import SwiftUI

struct ThemeSongs: View {
    private let openingThemes: [Theme]?
    private let endingThemes: [Theme]?
    
    init(openingThemes: [Theme]?, endingThemes: [Theme]?) {
        self.openingThemes = openingThemes
        self.endingThemes = endingThemes
    }
    
    var body: some View {
        if let openingThemes = openingThemes {
            ScrollViewCarousel(title: "Openings") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top) {
                        ForEach(openingThemes.prefix(10)) { theme in
                            if let text = theme.text {
                                ThemeSong(text: text.formatThemeSong())
                            }
                        }
                    }
                    .padding(.horizontal, 17)
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
            }
        }
        if let endingThemes = endingThemes {
            ScrollViewCarousel(title: "Endings") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top) {
                        ForEach(endingThemes.prefix(10)) { theme in
                            if let text = theme.text {
                                ThemeSong(text: text.formatThemeSong())
                            }
                        }
                    }
                    .padding(.horizontal, 17)
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
            }
        }
    }
}

struct ThemeSong: View {
    @Environment(\.screenSize) private var screenSize
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var settings: SettingsManager
    @State private var isCopied = false
    private let text: String
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack {
            Text(text)
            Spacer()
            Button {
                isCopied = true
                UIPasteboard.general.string = text
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    isCopied = false
                })
            } label: {
                Image(systemName: isCopied ? "checkmark" : "document.on.document")
                    .foregroundStyle(settings.getAccentColor())
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.bordered)
            .contentTransition(.symbolEffect(.replace))
            .sensoryFeedback(.impact(weight: .light), trigger: isCopied)
        }
            .multilineTextAlignment(.leading)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
            .font(.system(size: 17))
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .frame(width: min(450, screenSize.width - 34), alignment: .center)
            .frame(minHeight: 100)
            .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
            .shadow(radius: 0.5)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

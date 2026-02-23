
//
//  ThemeSongs.swift
//  Hako
//
//  Created by Gao Tianrun on 13/5/25.
//

import SwiftUI

struct ThemeSongs: View {
    @Environment(\.screenSize) private var screenSize
    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric private var height = 100
    private let openingThemes: [Theme]?
    private let endingThemes: [Theme]?
    
    init(openingThemes: [Theme]?, endingThemes: [Theme]?) {
        self.openingThemes = openingThemes
        self.endingThemes = endingThemes
    }
    
    @ViewBuilder private func ThemeSong(_ text: String) -> some View {
        HStack {
            Text(text)
            Spacer()
            CopySongButton(text: text)
        }
            .multilineTextAlignment(.leading)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
            .font(.callout)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .frame(width: min(450, screenSize.width - 34), height: height, alignment: .center)
            .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
            .shadow(radius: 0.5)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    var body: some View {
        if let openingThemes = openingThemes {
            ScrollViewCarousel(title: "Openings", count: openingThemes.count, viewAlignedScroll: true) {
                ForEach(openingThemes.prefix(10)) { theme in
                    if let text = theme.text?.formatThemeSong() {
                        ThemeSong(text)
                    }
                }
            } destination: {
                ThemesListView(themes: openingThemes)
            }
        }
        if let endingThemes = endingThemes {
            ScrollViewCarousel(title: "Endings", count: endingThemes.count, viewAlignedScroll: true) {
                ForEach(endingThemes.prefix(10)) { theme in
                    if let text = theme.text?.formatThemeSong() {
                        ThemeSong(text)
                    }
                }
            } destination: {
                ThemesListView(themes: endingThemes)
            }
        }
    }
}


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
    @State private var openingPreview: [Theme] = []
    @State private var endingPreview: [Theme] = []
    private let openingThemes: [Theme]?
    private let endingThemes: [Theme]?
    
    init(openingThemes: [Theme]?, endingThemes: [Theme]?) {
        self.openingThemes = openingThemes
        self.endingThemes = endingThemes
    }
    
    private func ThemeSong(_ text: String) -> some View {
        HStack {
            Text(text)
            Spacer()
            CopySongButton(text: text)
        }
            .multilineTextAlignment(.leading)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
            .padding(20)
            .frame(width: min(450, screenSize.width - 34), alignment: .center)
            .frame(maxHeight: .infinity)
            .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
            .shadow(radius: 0.5)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    var body: some View {
        if let openingThemes = openingThemes {
            ScrollViewCarousel(title: "Openings", count: openingThemes.count, viewAlignedScroll: true) {
                ForEach(openingPreview) { theme in
                    if let text = theme.text?.formatThemeSong() {
                        ThemeSong(text)
                    }
                }
            } destination: {
                ThemesListView(themes: openingThemes)
            }
            .onAppear {
                openingPreview = Array(openingThemes.prefix(10))
            }
        }
        if let endingThemes = endingThemes {
            ScrollViewCarousel(title: "Endings", count: endingThemes.count, viewAlignedScroll: true) {
                ForEach(endingPreview) { theme in
                    if let text = theme.text?.formatThemeSong() {
                        ThemeSong(text)
                    }
                }
            } destination: {
                ThemesListView(themes: endingThemes)
            }
            .onAppear {
                endingPreview = Array(endingThemes.prefix(10))
            }
        }
    }
}

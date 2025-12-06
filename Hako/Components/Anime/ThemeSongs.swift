
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
    private let openingThemes: [Theme]?
    private let endingThemes: [Theme]?
    
    init(openingThemes: [Theme]?, endingThemes: [Theme]?) {
        self.openingThemes = openingThemes
        self.endingThemes = endingThemes
    }
    
    var body: some View {
        if let openingThemes = openingThemes {
            ScrollViewCarousel(title: "Openings", items: openingThemes) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top) {
                        ForEach(openingThemes.prefix(10)) { theme in
                            if let text = theme.text?.formatThemeSong() {
                                HStack {
                                    Text(text)
                                    Spacer()
                                    CopySongButton(text: text)
                                }
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(3)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .font(.system(size: 17))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .frame(width: min(450, screenSize.width - 34), height: 100, alignment: .center)
                                    .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
                                    .shadow(radius: 0.5)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .padding(.horizontal, 17)
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
            } destination: {
                ThemesListView(themes: openingThemes)
            }
        }
        if let endingThemes = endingThemes {
            ScrollViewCarousel(title: "Endings", items: endingThemes) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top) {
                        ForEach(endingThemes.prefix(10)) { theme in
                            if let text = theme.text?.formatThemeSong() {
                                HStack {
                                    Text(text)
                                    Spacer()
                                    CopySongButton(text: text)
                                }
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(3)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .font(.system(size: 17))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .frame(width: min(450, screenSize.width - 34), height: 100, alignment: .center)
                                    .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
                                    .shadow(radius: 0.5)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .padding(.horizontal, 17)
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
            } destination: {
                ThemesListView(themes: endingThemes)
            }
        }
    }
}

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
            Section {} header: {
                VStack {
                    ListViewLink(title: "Openings", items: openingThemes) {
                        ThemesListView(themes: openingThemes)
                            .navigationTitle("Openings")
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            ForEach(openingThemes.prefix(10)) { theme in
                                if let text = theme.text {
                                    ThemeSong(text: text.formatThemeSong())
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .textCase(nil)
                .padding(.horizontal, -20)
                .foregroundColor(Color.primary)
                .listRowInsets(.init())
            }
            .frame(maxWidth: .infinity)
            .listRowInsets(.init())
        }
        if let endingThemes = endingThemes {
            Section {} header: {
                VStack {
                    ListViewLink(title: "Endings", items: endingThemes) {
                        ThemesListView(themes: endingThemes)
                            .navigationTitle("Endings")
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            ForEach(endingThemes.prefix(10)) { theme in
                                if let text = theme.text {
                                    ThemeSong(text: text.formatThemeSong())
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .textCase(nil)
                .padding(.horizontal, -20)
                .foregroundColor(Color.primary)
                .listRowInsets(.init())
            }
            .frame(maxWidth: .infinity)
            .listRowInsets(.init())
        }
    }
}

struct ThemeSong: View {
    @Environment(\.colorScheme) var colorScheme
    private let text: String
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .textSelection(.enabled)
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
            .font(.system(size: 17))
            .padding(20)
            .frame(width: UIScreen.main.bounds.size.width - 30, height: 100, alignment: .center)
            .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
            .shadow(radius: 0.5)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

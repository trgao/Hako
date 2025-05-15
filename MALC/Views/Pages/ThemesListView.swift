//
//  ThemesListView.swift
//  MALC
//
//  Created by Gao Tianrun on 15/5/25.
//

import SwiftUI

struct ThemesListView: View {
    private let themes: [Theme]
    
    init(themes: [Theme]) {
        self.themes = themes
    }
    
    var body: some View {
        List {
            ForEach(themes) { theme in
                if let text = theme.text {
                    Label(text, systemImage: "music.note")
                }
            }
        }
        .alignmentGuide(.listRowSeparatorLeading) { _ in
            return -15
        }
    }
}

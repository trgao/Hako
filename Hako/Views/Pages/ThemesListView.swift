//
//  ThemesListView.swift
//  Hako
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
                        .contextMenu {
                            Button {
                                UIPasteboard.general.string = text
                            } label: {
                                Label("Copy song", systemImage: "document.on.document")
                            }
                        }
                }
            }
        }
    }
}

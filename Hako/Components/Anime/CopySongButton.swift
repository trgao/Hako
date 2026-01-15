//
//  CopySongButton.swift
//  Hako
//
//  Created by Gao Tianrun on 6/12/25.
//

import SwiftUI

struct CopySongButton: View {
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var settings: SettingsManager
    @State private var isCopied = false
    private let text: String
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        if settings.hideThemeSongsSearch {
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
        } else {
            Menu {
                Button {
                    UIPasteboard.general.string = text
                } label: {
                    Label("Copy", systemImage: "document.on.document")
                }
                let spotifyUrl = URL(string: "spotify://search/\(text)")!
                if UIApplication.shared.canOpenURL(spotifyUrl) {
                    Button {
                        openURL(spotifyUrl)
                    } label: {
                        Label("Search in Spotify", systemImage: "magnifyingglass")
                    }
                }
                if let url = URL(string: "https://music.apple.com/search?term=\(text)") {
                    Button {
                        openURL(url)
                    } label: {
                        Label("Search in Apple Music", systemImage: "magnifyingglass")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .padding(.vertical, 5)
            }
            .buttonStyle(.bordered)
        }
    }
}

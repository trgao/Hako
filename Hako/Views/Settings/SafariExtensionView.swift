//
//  SafariExtensionView.swift
//  Hako
//
//  Created by Gao Tianrun on 30/1/26.
//

import SwiftUI

struct SafariExtensionView: View {
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var settings: SettingsManager
    
    var body: some View {
        VStack {
            Label("Open in Hako", systemImage: "puzzlepiece.extension.fill")
                .bold()
                .font(.title)
                .tint(settings.getAccentColor())
            Text("You can turn on Hako's Safari extension in Settings, under Apps > Safari > Extensions > Open in Hako. The extension will allow you to open MyAnimeList links in this app instead.")
                .padding(.vertical, 20)
            Button("Go to settings") {
                if let url = URL(string: "App-Prefs:com.apple.mobilesafari") {
                    openURL(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
    }
}

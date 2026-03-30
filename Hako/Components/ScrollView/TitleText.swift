//
//  TitleText.swift
//  Hako
//
//  Created by Gao Tianrun on 7/6/24.
//

import SwiftUI

struct TitleText: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var settings: SettingsManager
    private let romaji: String
    private let english: String?
    private let japanese: String?
    private var title: String {
        if let title = english, !title.isEmpty && settings.preferredTitleLanguage == 1 {
            return title
        } else {
            return romaji
        }
    }
    
    init(romaji: String, english: String? = nil, japanese: String? = nil) {
        self.romaji = romaji
        self.english = english
        self.japanese = japanese
    }
    
    var text: some View {
        VStack {
            Text(title)
                .bold()
                .font(UIDevice.current.userInterfaceIdiom == .phone ? .title2 : .title)
                .multilineTextAlignment(.center)
            if let japanese = japanese {
                Text(japanese)
                    .opacity(0.7)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .center)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    var body: some View {
        text
            .contextMenu {
                Button {
                    UIPasteboard.general.string = romaji
                } label: {
                    Text("Copy romaji title")
                    Text(romaji)
                }
                if let english = english, !english.isEmpty {
                    Button {
                        UIPasteboard.general.string = english
                    } label: {
                        Text("Copy english title")
                        Text(english)
                    }
                }
                if let japanese = japanese, !japanese.isEmpty {
                    Button {
                        UIPasteboard.general.string = japanese
                    } label: {
                        Text("Copy native language title")
                        Text(japanese)
                    }
                }
            }
    }
}

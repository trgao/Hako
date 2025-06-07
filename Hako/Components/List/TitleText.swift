//
//  TitleText.swift
//  Hako
//
//  Created by Gao Tianrun on 7/6/24.
//

import SwiftUI

struct TitleText: View {
    @EnvironmentObject private var settings: SettingsManager
    private let romaji: String
    private let english: String?
    private let japanese: String?
    
    init(romaji: String, english: String? = nil, japanese: String? = nil) {
        self.romaji = romaji
        self.english = english
        self.japanese = japanese
    }
    
    var body: some View {
        Menu {
            Button {
                UIPasteboard.general.string = romaji
            } label: {
                Text("Copy Romaji title")
                Text(romaji)
            }
            if let english = english {
                Button {
                    UIPasteboard.general.string = english
                } label: {
                    Text("Copy English title")
                    Text(english)
                }
            }
            if let japanese = japanese {
                Button {
                    UIPasteboard.general.string = japanese
                } label: {
                    Text("Copy Japanese title")
                    Text(japanese)
                }
            }
        } label: {
            VStack {
                if let title = english, !title.isEmpty && settings.preferredTitleLanguage == 1 {
                    Text(title)
                        .bold()
                        .font(.system(size: 25))
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)
                        .contentShape(Rectangle())
                } else {
                    Text(romaji)
                        .bold()
                        .font(.system(size: 25))
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)
                        .contentShape(Rectangle())
                }
                if let japanese = japanese {
                    Text(japanese)
                        .padding(.bottom, 5)
                        .padding(.horizontal, 20)
                        .font(.system(size: 18))
                        .opacity(0.7)
                        .multilineTextAlignment(.center)
                }
            }
        } primaryAction: {}
    }
}

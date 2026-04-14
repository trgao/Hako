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
    private let native: String?
    private var title: String {
        settings.getTitle(romaji: romaji, english: english, native: native)
    }
    
    init(romaji: String, english: String? = nil, native: String? = nil) {
        self.romaji = romaji
        self.english = english
        self.native = native
    }
    
    var body: some View {
        VStack {
            Text(title)
                .bold()
                .font(UIDevice.current.userInterfaceIdiom == .phone ? .title2 : .title)
                .multilineTextAlignment(.center)
            Group {
                if settings.preferredTitleLanguage == 2 {
                    if let english = english, !english.isEmpty {
                        Text(english)
                    } else {
                        Text(romaji)
                    }
                } else if let native = native, !native.isEmpty && settings.preferredTitleLanguage != 2 {
                    Text(native)
                }
            }
            .opacity(0.7)
            .multilineTextAlignment(.center)
        }
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .center)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
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
            if let native = native, !native.isEmpty {
                Button {
                    UIPasteboard.general.string = native
                } label: {
                    Text("Copy native language title")
                    Text(native)
                }
            }
        }
    }
}

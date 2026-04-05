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
    private let native: String?
    private var title: String {
        settings.getTitle(romaji: romaji, english: english, native: native)
    }
    
    init(romaji: String, english: String? = nil, native: String? = nil) {
        self.romaji = romaji
        self.english = english
        self.native = native
    }
    
    var text: some View {
        VStack {
            Text(title)
                .bold()
                .font(UIDevice.current.userInterfaceIdiom == .phone ? .title2 : .title)
                .multilineTextAlignment(.center)
            Group {
                if let english = english, settings.preferredTitleLanguage == 2 {
                    Text(english)
                } else if let native = native {
                    Text(native)
                }
            }
            .opacity(0.7)
            .multilineTextAlignment(.center)
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

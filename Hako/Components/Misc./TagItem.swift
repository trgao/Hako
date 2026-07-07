//
//  TagItem.swift
//  Hako
//
//  Created by Gao Tianrun on 27/3/26.
//

import SwiftUI

struct TagItem: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var settings: SettingsManager
    private let text: String
    private let systemImage: String?
    
    init(text: String, systemImage: String? = nil) {
        self.text = text
        self.systemImage = systemImage
    }
    
    var body: some View {
        var background: Color {
            if text == "Recommended" {
                return .green
            } else if text == "Not Recommended" {
                return .red
            } else if text == "Mixed Feelings" {
                return .gray
            } else {
                return settings.getAccentColor()
            }
        }
        var textColor: Color {
            if background == .green || background == .teal || background == .orange {
                return .black
            } else {
                return .white
            }
        }
        Group {
            if let systemImage = systemImage {
                Label(text, systemImage: systemImage)
            } else {
                Text(text)
            }
        }
        .font(.footnote)
        .padding(8)
        .foregroundStyle(textColor)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

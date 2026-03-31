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
    
    init(text: String) {
        self.text = text
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
        Text(text)
            .font(.footnote)
            .padding(8)
            .foregroundStyle(textColor)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

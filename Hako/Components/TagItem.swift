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
    private let greenTexts = ["Recommended", "10 ⭐", "9 ⭐", "8 ⭐", "7 ⭐"]
    private let redTexts = ["Not Recommended", "4 ⭐", "3 ⭐", "2 ⭐", "1 ⭐"]
    private let greyTexts = ["Mixed Feelings", "6 ⭐", "5 ⭐"]
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        var background: Color {
            if greenTexts.contains(text) {
                return .green
            } else if redTexts.contains(text) {
                return .red
            } else if greyTexts.contains(text) {
                return Color(.systemGray3)
            } else {
                return settings.getAccentColor()
            }
        }
        var textColor: Color {
            if background == .green || background == .teal || background == .orange || background == .green {
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

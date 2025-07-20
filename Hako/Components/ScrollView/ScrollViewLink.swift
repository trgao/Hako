//
//  ScrollViewLink.swift
//  Hako
//
//  Created by Gao Tianrun on 20/7/25.
//

import SwiftUI

struct ScrollViewLink: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) private var openURL
    @State private var isPressed = false
    private let text: String
    private let url: String
    
    init(text: String, url: String) {
        self.text = text
        self.url = url
    }
    
    var body: some View {
        HStack {
            Text(text)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isPressed = true
            openURL(URL(string: url)!)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isPressed = false
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .background(isPressed ? Color(.systemGray3) : (colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6)))
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
    }
}

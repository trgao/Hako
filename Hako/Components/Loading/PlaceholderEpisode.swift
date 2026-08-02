//
//  PlaceholderEpisode.swift
//  Hako
//
//  Created by Gao Tianrun on 7/7/26.
//

import SwiftUI

struct PlaceholderEpisode: View {
    @Environment(\.screenSize) private var screenSize
    @Environment(\.colorScheme) private var colorScheme
    private let isLoading: Bool
    
    init(isLoading: Bool = true) {
        self.isLoading = isLoading
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("placeholderplaceholder")
            Text("placeholder")
                .opacity(0.7)
                .font(.footnote)
            Text("placeholder")
                .opacity(0.7)
                .font(.footnote)
            HStack {
                TagItem(text: "Recap")
                Spacer()
                Label("Forum", systemImage: "bubble.left.and.bubble.right.fill")
            }
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .padding(20)
        .frame(width: min(450, screenSize.width - 34), alignment: .center)
        .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
        .shadow(radius: 0.5)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .skeleton(isLoading)
    }
}


//
//  BigPlaceholderGridItem.swift
//  Hako
//
//  Created by Gao Tianrun on 15/3/26.
//

import SwiftUI

struct BigPlaceholderGridItem: View {
    @Environment(\.screenRatio) private var screenRatio
    @EnvironmentObject private var settings: SettingsManager
    private let isLoading: Bool
    
    init(isLoading: Bool = true) {
        self.isLoading = isLoading
    }
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.gray)
                .opacity(0.6)
                .frame(width: 150 * screenRatio, height: 213 * screenRatio)
            Text("placeholderplaceholderplaceholderplaceholderplaceholderplaceholderplaceholder")
                .lineLimit(settings.getLineLimit() ?? 2)
                .frame(width: 150 * screenRatio, alignment: .leading)
                .padding(5)
                .font(.callout)
        }
        .padding(5)
        .skeleton(isLoading)
    }
}

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
            ImageFrame(id: "", imageUrl: nil, imageSize: .large)
            Text("placeholderplaceholderplaceholderplaceholderplaceholderplaceholderplaceholder")
                .lineLimit(settings.getLineLimit() ?? 2)
                .frame(width: 150 * screenRatio, alignment: .leading)
                .padding(5)
                .font(.callout)
                .tint(.primary)
        }
        .skeleton(isLoading)
    }
}

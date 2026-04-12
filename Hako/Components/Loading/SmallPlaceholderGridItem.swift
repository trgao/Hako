//
//  SmallPlaceholderGridItem.swift
//  Hako
//
//  Created by Gao Tianrun on 15/3/26.
//

import SwiftUI

struct SmallPlaceholderGridItem: View {
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
                .frame(width: 100 * screenRatio, height: 142 * screenRatio)
            Text("placeholderplaceholderplaceholderplaceholderplaceholderplaceholderplaceholder")
                .frame(width: 100 * screenRatio)
                .lineLimit(settings.getLineLimit() ?? 2)
                .font(.footnote)
        }
        .frame(width: 110 * screenRatio)
        .skeleton(isLoading)
    }
}

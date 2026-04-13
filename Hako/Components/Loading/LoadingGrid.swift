//
//  LoadingGrid.swift
//  Hako
//
//  Created by Gao Tianrun on 13/4/26.
//

import SwiftUI

struct LoadingGrid: View {
    @Environment(\.screenRatio) private var screenRatio
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150 * screenRatio), spacing: 5, alignment: .top)]) {
                ForEach(0..<50, id: \.self) { _ in
                    BigPlaceholderGridItem()
                }
            }
            .padding(10)
        }
        .disabled(true)
    }
}

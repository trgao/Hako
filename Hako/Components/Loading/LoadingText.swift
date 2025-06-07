//
//  LoadingText.swift
//  Hako
//
//  Created by Gao Tianrun on 14/5/25.
//

import SwiftUI
import Shimmer

struct LoadingText<T>: View {
    private let content: T?
    
    init(content: T?) {
        self.content = content
    }
    
    var body: some View {
        if let content = content {
            Text("\(content)")
                .textSelection(.enabled)
        } else {
            Text("example")
                .redacted(reason: .placeholder)
                .shimmering()
        }
    }
}

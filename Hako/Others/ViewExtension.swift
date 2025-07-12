//
//  ViewExtension.swift
//  Hako
//
//  Created by Gao Tianrun on 12/7/25.
//

import SwiftUI

extension View {
    @MainActor func render(scale displayScale: CGFloat = 1.0) -> UIImage? {
        let renderer = ImageRenderer(content: self)

        renderer.scale = displayScale
        
        return renderer.uiImage
    }
}

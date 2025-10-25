//
//  UIImageExtension.swift
//  Hako
//
//  Created by Gao Tianrun on 25/10/25.
//

import SwiftUI

extension UIImage {
    func removingAlpha() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true // removes Alpha Channel
        format.scale = scale // keeps original image scale
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

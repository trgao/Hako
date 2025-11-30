//
//  IconTintLabelStyle.swift
//  Code taken from https://danielsaidi.com/blog/2024/04/04/creating-a-custom-swiftui-labelstyle-that-tints-the-label-icon
//

import SwiftUI

struct IconTintLabelStyle: LabelStyle {
    private let color: Color

    init(_ color: Color) {
        self.color = color
    }

    func makeBody(configuration: Configuration) -> some View {
        Label(
            title: { configuration.title },
            icon: { configuration.icon.foregroundStyle(color) }
        )
    }
}

extension LabelStyle where Self == IconTintLabelStyle {
    static func iconTint(_ color: Color) -> Self {
        .init(color)
    }
}

//
//  ReducedSpaceLabelStyle.swift
//  Code taken from https://www.hackingwithswift.com/forums/swiftui/reduce-the-space-between-a-label-s-title-and-icon/22983/22984
//

import SwiftUI

struct ReducedSpaceLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 3) {
            configuration.icon
            configuration.title
        }
    }
}

extension LabelStyle where Self == ReducedSpaceLabelStyle {
    static var reducedSpace: Self {
        .init()
    }
}

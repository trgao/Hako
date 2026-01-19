//
//  CustomLabelStyle.swift
//  Code taken from https://www.hackingwithswift.com/forums/swiftui/reduce-the-space-between-a-label-s-title-and-icon/22983/22984
//

import SwiftUI

struct CustomLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 2) {
            configuration.icon
            configuration.title
        }
    }
}

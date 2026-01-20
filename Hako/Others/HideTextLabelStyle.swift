//
//  HideTextLabelStyle.swift
//  Hako
//
//  Created by Gao Tianrun on 20/1/26.
//

import SwiftUI

struct HideTextLabelStyle: LabelStyle {
    private let showText: Bool
    
    init(_ showText: Bool) {
        self.showText = showText
    }
    
    func makeBody(configuration: Configuration) -> some View {
        if showText {
            DefaultLabelStyle().makeBody(configuration: configuration)
        } else {
            configuration.icon
        }
    }
}

//
//  HideTextLabelStyle.swift
//  Hako
//
//  Created by Gao Tianrun on 20/1/26.
//

import SwiftUI

struct HideTextLabelStyle: LabelStyle {
    @EnvironmentObject private var settings: SettingsManager
    func makeBody(configuration: Configuration) -> some View {
        if settings.swipeActionText {
            DefaultLabelStyle().makeBody(configuration: configuration)
        } else {
            configuration.icon
        }
    }
}

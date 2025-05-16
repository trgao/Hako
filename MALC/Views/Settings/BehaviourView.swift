//
//  BehaviourView.swift
//  MALC
//
//  Created by Gao Tianrun on 20/11/24.
//

import SwiftUI

struct BehaviourView: View {
    @EnvironmentObject private var settings: SettingsManager
    
    var body: some View {
        List {
            PickerRow(title: "Default view", selected: $settings.defaultView, array: ["Top", "Seasons", "Search", "My List"])
        }
    }
}

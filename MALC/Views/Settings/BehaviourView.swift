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
            Picker("Default view", selection: $settings.defaultView) {
                Text("Top").tag(0)
                Text("Seasons").tag(1)
                Text("Search").tag(2)
                Text("My List").tag(3)
            }
            .pickerStyle(.menu)
        }
    }
}

//
//  HakoApp.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

@main
struct HakoApp: App {
    @StateObject private var settings = SettingsManager()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(settings)
                .preferredColorScheme(settings.getColorScheme())
                .tint(settings.getAccentColor())
        }
    }
}

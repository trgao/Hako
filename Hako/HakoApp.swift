//
//  HakoApp.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import Network

@main
struct HakoApp: App {
    @StateObject private var settings = SettingsManager()
    
    init() {
        Task {
            await CacheManager.shared.clearTemp()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                MainView()
                    .environment(\.screenSize, geometry.size)
                    .environmentObject(settings)
                    .preferredColorScheme(settings.getColorScheme())
                    .tint(settings.getAccentColor())
            }
        }
    }
}

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
    @State private var networkMonitor = NetworkMonitor()
    @State private var showNetworkAlert = false
    
    init() {
        Task {
            await CacheManager.shared.clearTemp()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { proxy in
                MainView()
                    .environment(\.screenSize, proxy.size)
                    .environmentObject(settings)
                    .preferredColorScheme(settings.getColorScheme())
                    .tint(settings.getAccentColor())
                    .onChange(of: networkMonitor.isConnected) { _, cur in
                        showNetworkAlert = !cur
                    }
                    .alert(
                        "Network connection seems to be offline. Please reconnect to Wifi. ",
                        isPresented: $showNetworkAlert
                    ) {}
            }
        }
    }
}

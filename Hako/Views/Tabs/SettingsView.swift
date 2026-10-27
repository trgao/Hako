//
//  SettingsView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import AuthenticationServices

struct SettingsView: View {
    @Environment(Router.self) private var router
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var networker = NetworkManager.shared
    @State private var isLoadingStatus = false

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            List {
                if !settings.useWithoutAccount {
                    SignInSections(isSettings: true)
                }
                Section {
                    TrackedNavigationLink(value: "general") {
                        Label("General", systemImage: "gear")
                    }
                    TrackedNavigationLink(value: "appearance") {
                        Label("Appearance", systemImage: "paintpalette.fill")
                    }
                    TrackedNavigationLink(value: "customise") {
                        Label("Customise", systemImage: "slider.horizontal.3")
                    }
                }
                if !ProcessInfo.processInfo.isMacCatalystApp {
                    Section {
                        TrackedNavigationLink(value: "safariExtension") {
                            Label("Safari extension", systemImage: "puzzlepiece.extension.fill")
                        }
                    }
                }
                Section {
                    TrackedNavigationLink(value: "about") {
                        Label("About", systemImage: "info.circle")
                    }
                    Link(destination: URL(string: "https://forms.gle/v2ewpgxHLDL16kK8A")!) {
                        Label("Feedback", systemImage: "exclamationmark.bubble.fill")
                    }
                }
                Section {
                    Link(destination: URL(string: "https://tenrai.org/status")!) {
                        Label("API status", systemImage: "exclamationmark.icloud.fill")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationDestinations()
        }
    }
}

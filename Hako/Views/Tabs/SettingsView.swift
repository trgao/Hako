//
//  SettingsView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import AuthenticationServices

struct SettingsView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject var networker = NetworkManager.shared
    
    var body: some View {
        NavigationStack {
            List {
                if !settings.useWithoutAccount {
                    SignInSections(isSettings: true)
                }
                Section {
                    NavigationLink {
                        GeneralView()
                    } label: {
                        Label("General", systemImage: "gear")
                    }
                    NavigationLink {
                        AppearanceView()
                    } label: {
                        Label("Appearance", systemImage: "paintpalette.fill")
                    }
                    NavigationLink {
                        HideItemsView()
                    } label: {
                        Label("Hide items", systemImage: "eye.slash.fill")
                    }
                }
                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

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
                        Label {
                            Text("General")
                        } icon: {
                            Image(systemName: "gear")
                                .foregroundStyle(.primary)
                        }
                    }
                    NavigationLink {
                        AppearanceView()
                    } label: {
                        Label {
                            Text("Appearance")
                        } icon: {
                            Image(systemName: "paintpalette.fill")
                                .foregroundStyle(.purple)
                        }
                    }
                    NavigationLink {
                        Text("Information")
                    } label: {
                        Label {
                            Text("Information")
                        } icon: {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

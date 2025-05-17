//
//  AppearanceView.swift
//  Hako
//
//  Created by Gao Tianrun on 20/11/24.
//

import SwiftUI

struct AppearanceView: View {
    @EnvironmentObject private var settings: SettingsManager
    @State private var altIcon = false
    @State private var isChangeIconError = false
    
    var body: some View {
        List {
            Section("Grid view") {
                Toggle(isOn: $settings.truncate) {
                    Text("Truncate titles or names")
                }
                PickerRow(title: "Line limit", selected: $settings.lineLimit, array: ["1", "2", "3"])
                    .disabled(!settings.truncate)
            }
            PickerRow(title: "App theme", selected: $settings.colorScheme, array: ["System", "Light", "Dark"])
            Section {
                HStack {
                    ForEach(Array(settings.accentColors.enumerated()), id: \.offset) { index, color in
                        Button {
                            settings.accentColor = index
                        } label: {
                            Image(systemName: "circle.fill")
                                .foregroundStyle(color)
                                .tag(index)
                        }
                        .buttonStyle(.plain)
                        .padding(2)
                        .overlay {
                            if settings.accentColor == index {
                                Circle()
                                    .stroke(color, lineWidth: 2)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            } header: {
                Text("Accent color")
            }
            Section {
                HStack {
                    Button {
                        if UIApplication.shared.supportsAlternateIcons {
                            UIApplication.shared.setAlternateIconName(nil) { error in
                                if let _ = error {
                                    isChangeIconError = true
                                } else {
                                    altIcon = false
                                }
                            }
                        } else {
                            print("Not supported")
                            isChangeIconError = true
                        }
                    } label: {
                        Image(uiImage: UIImage(named: "AppIcon.png")!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay {
                                if !altIcon {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(settings.getAccentColor(), lineWidth: 3)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 50)
                    Button {
                        if UIApplication.shared.supportsAlternateIcons {
                            UIApplication.shared.setAlternateIconName("AltAppIcon") { error in
                                if let _ = error {
                                    isChangeIconError = true
                                } else {
                                    altIcon = true
                                }
                            }
                        } else {
                            print("Not supported")
                            isChangeIconError = true
                        }
                    } label: {
                        Image(uiImage: UIImage(named: "AltAppIcon.png")!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay {
                                if altIcon {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(settings.getAccentColor(), lineWidth: 3)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            } header: {
                Text("App icon")
            }
            Section("Accessibility") {
                Toggle(isOn: $settings.translucentBackground) {
                    Text("Allow translucent backgrounds")
                }
            }
        }
        .alert("Unable to change app icon", isPresented: $isChangeIconError) {
            Button("OK", role: .cancel) {}
        }
    }
}

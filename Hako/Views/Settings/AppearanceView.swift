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
            Section("General") {
                PickerRow(title: "App theme", selection: $settings.colorScheme, labels: ["System", "Light", "Dark"])
            }
            Section("Accent color") {
                HStack {
                    ForEach(Array(Constants.accentColors.enumerated()), id: \.offset) { index, color in
                        Button {
                            settings.accentColor = index
                        } label: {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 13))
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
            }
            Section("App icon") {
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
            }
            Section("Accessibility") {
                Toggle(isOn: $settings.translucentBackground) {
                    Text("Allow translucent backgrounds")
                }
                Toggle(isOn: $settings.dynamicType) {
                    Text("Allow dynamic type")
                    Text("Allow changes in Settings app under Accessibility > Display & Text Size > Larger Text to apply in this app")
                }
            }
            Section("Text") {
                Toggle(isOn: $settings.truncate) {
                    Text("Truncate titles or names")
                    Text("Limit length of titles or names to a maximum number of lines")
                }
                PickerRow(title: "Line limit", selection: $settings.lineLimit, labels: ["1", "2", "3"])
                    .disabled(!settings.truncate)
            }
        }
        .alert("Unable to change app icon", isPresented: $isChangeIconError) {
            Button("Ok") {}
        }
    }
}

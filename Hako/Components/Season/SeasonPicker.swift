//
//  SeasonPicker.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct SeasonPicker: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject var controller: SeasonsViewController
    @State private var season = ["winter", "spring", "summer", "fall"][((Calendar(identifier: .gregorian).dateComponents([.month], from: .now).month ?? 9) - 1) / 3]
    
    init(controller: SeasonsViewController) {
        self._controller = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 40)
                .foregroundColor(Color(.systemGray6))
            Picker(selection: $controller.season, label: EmptyView()) {
                Text("Winter").tag("winter")
                Text("Spring").tag("spring")
                Text("Summer").tag("summer")
                Text("Fall").tag("fall")
            }
            .sensoryFeedback(.impact(weight: .light), trigger: controller.season)
            .onChange(of: controller.season) {
                if controller.shouldRefresh() {
                    Task {
                        await controller.refresh()
                    }
                }
            }
            .pickerStyle(.segmented)
            .padding(5)
        }
        .padding(.bottom, 5)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

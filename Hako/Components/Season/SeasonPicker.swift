//
//  SeasonPicker.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//
import SwiftUI

struct SeasonPicker: View {
    @StateObject private var controller: SeasonsViewController
    
    init(controller: SeasonsViewController) {
        self._controller = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.regularMaterial)
                .frame(height: 42)
            Picker(selection: $controller.season, label: EmptyView()) {
                Text("Winter").tag("winter")
                Text("Spring").tag("spring")
                Text("Summer").tag("summer")
                Text("Fall").tag("fall")
            }
            .pickerStyle(.segmented)
            .padding(5)
            .sensoryFeedback(.impact(weight: .light), trigger: controller.season)
            .task(id: controller.season) {
                if controller.shouldRefresh() {
                    await controller.refresh()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(5)
    }
}

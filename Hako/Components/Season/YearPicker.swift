//
//  YearPicker.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct YearPicker: View {
    @StateObject private var controller: SeasonsViewController
    private let currentYear = Calendar(identifier: .gregorian).dateComponents([.year], from: .now).year ?? 2001
    
    init(controller: SeasonsViewController) {
        self._controller = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        Menu {
            Picker(selection: $controller.year, label: EmptyView()) {
                ForEach((1917...currentYear + 1).reversed(), id: \.self) { year in
                    Text(String(year)).tag(String(year))
                }
            }
            .onChange(of: controller.year) {
                Task {
                    await controller.refresh(true)
                }
            }
        } label: {
            Button(String(controller.year)) {}
                .buttonStyle(.borderedProminent)
        }
    }
}

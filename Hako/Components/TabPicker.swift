//
//  TabPicker.swift
//  Hako
//
//  Created by Gao Tianrun on 30/9/25.
//

import SwiftUI

struct TabPicker<T: Hashable>: View {
    @Binding private var selection: T
    private let options: [(String, T)]
    private let refresh: () async -> Void
    
    init(selection: Binding<T>, options: [(String, T)], refresh: @escaping () async -> Void) {
        self._selection = selection
        self.options = options
        self.refresh = refresh
    }
    
    private func getPadding() -> CGFloat {
        if #available(iOS 26.0, *) {
            return 20
        } else {
            return 5
        }
    }
    
    var body: some View {
        ZStack {
            if #available(iOS 26.0, *) {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(.white.opacity(0.8))
                    .glassEffect(.regular)
                    .frame(height: 42)
                    .padding(.horizontal, 15)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.regularMaterial)
                    .frame(height: 42)
            }
            Picker(selection: $selection, label: EmptyView()) {
                ForEach(options, id: \.0) { key, value in
                    Text(key).tag(value)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, getPadding())
            .sensoryFeedback(.impact(weight: .light), trigger: selection)
            .task(id: selection) {
                await refresh()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(5)
    }
}

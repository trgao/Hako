//
//  TabPicker.swift
//  Hako
//
//  Created by Gao Tianrun on 30/9/25.
//

import SwiftUI

struct TabPicker<T: Hashable>: View {
    @Environment(\.colorScheme) private var colorScheme
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
            return 12
        }
    }
    
    var body: some View {
        ZStack {
            if #available(iOS 26.0, *) {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle((colorScheme == .light ? Color.white : Color.black).opacity(0.6))
                    .glassEffect(.regular)
                    .padding(.horizontal, 15)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.regularMaterial)
                    .padding(.horizontal, 7)
            }
            Picker(selection: $selection, label: EmptyView()) {
                ForEach(options, id: \.0) { key, value in
                    Text(key).tag(value)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, getPadding())
            .padding(.bottom, 1)
            .sensoryFeedback(.impact(weight: .light), trigger: selection)
            .task(id: selection) {
                await refresh()
            }
        }
        .frame(height: 42)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(5)
    }
}

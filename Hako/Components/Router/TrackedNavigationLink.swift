//
//  TrackedNavigationLink.swift
//  Hako
//
//  Created by Gao Tianrun on 23/10/26.
//

import SwiftUI

struct TrackedNavigationLink<Item: Hashable, Label: View>: View {
    @Environment(Router.self) private var router
    private let item: Item
    private let label: () -> Label

    init(value: Item, label: @escaping () -> Label) {
        self.item = value
        self.label = label
    }

    init(value: Item, label: String) where Label == Text {
        self.item = value
        self.label = { Text(label) }
    }

    var body: some View {
        @Bindable var router = router
        NavigationLink(value: item) {
            Button {
                router.push(item)
            } label: {
                label()
            }
            .buttonStyle(.plain)
        }
    }
}

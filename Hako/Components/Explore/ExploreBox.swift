//
//  ExploreBox.swift
//  Hako
//
//  Created by Gao Tianrun on 6/7/26.
//

import SwiftUI

struct ExploreBox: View {
    @Environment(\.screenSize) private var screenSize
    @Environment(Router.self) private var router
    @EnvironmentObject private var settings: SettingsManager
    @State private var isPressed = false
    @State private var isLongPress = false
    private let item: String
    private let image: String

    init(item: String, image: String) {
        self.item = item
        self.image = image
    }

    var body: some View {
        VStack(alignment: .leading) {
            Label(item.capitalized, systemImage: image)
                .foregroundStyle(settings.getAccentColor())
                .frame(maxWidth: .infinity, alignment: .leading)
                .bold()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 15)
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
            isPressed = true
            if let screen = Screen(rawValue: item) {
                router.push(Route.screen(screen))
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isPressed = false
            }
        }
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            isLongPress = pressing
        }) {}
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(isPressed || isLongPress ? Color(.systemGray4) : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

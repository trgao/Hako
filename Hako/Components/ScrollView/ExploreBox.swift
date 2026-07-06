//
//  ExploreBox.swift
//  Hako
//
//  Created by Gao Tianrun on 6/7/26.
//

import SwiftUI

struct ExploreBox<Destination: View>: View {
    @Environment(\.screenSize) private var screenSize
    @EnvironmentObject private var settings: SettingsManager
    @State private var isPressed = false
    @State private var isLongPress = false
    private let title: String
    private let image: String
    private let destination: () -> Destination

    init(title: String, image: String, destination: @escaping () -> Destination) {
        self.title = title
        self.image = image
        self.destination = destination
    }

    var body: some View {
        VStack(alignment: .leading) {
            Label(title, systemImage: image)
                .foregroundStyle(settings.getAccentColor())
                .frame(maxWidth: .infinity, alignment: .leading)
                .bold()
        }
        .padding(20)
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
            isPressed = true
        }
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            isLongPress = pressing
        }) {}
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(isPressed || isLongPress ? Color(.systemGray4) : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .navigationDestination(isPresented: $isPressed, destination: destination)
    }
}

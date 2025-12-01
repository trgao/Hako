//
//  ScrollViewBox.swift
//  Hako
//
//  Created by Gao Tianrun on 1/12/25.
//

import SwiftUI

struct ScrollViewBox<Content: View>: View {
    @Environment(\.screenSize) private var screenSize
    @EnvironmentObject private var settings: SettingsManager
    @State private var isPressed = false
    @State private var isLongPress = false
    private let title: String
    private let image: String
    private let isFull: Bool
    private let destination: () -> Content
    
    init(title: String, image: String, isFull: Bool = false, destination: @escaping () -> Content) {
        self.title = title
        self.image = image
        self.isFull = isFull
        self.destination = destination
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: image)
                .foregroundStyle(settings.getAccentColor())
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            Text(title)
                .bold()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isPressed = true
        }
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            isLongPress = pressing
        }) {}
        .padding(20)
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(isPressed || isLongPress ? Color(.systemGray4) : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .navigationDestination(isPresented: $isPressed, destination: destination)
    }
}

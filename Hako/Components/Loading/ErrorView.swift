//
//  ErrorView.swift
//  Hako
//
//  Created by Gao Tianrun on 12/5/25.
//

import SwiftUI

struct ErrorView: View {
    private let refresh: () async -> Void

    init(refresh: @escaping () async -> Void) {
        self.refresh = refresh
    }

    var body: some View {
        ContentUnavailableView {
            Label("Unable to load", systemImage: "exclamationmark.triangle")
        } description: {
            Text("Check your connection and try again.")
        } actions: {
            Button("Try Again") {
                Task {
                    await refresh()
                }
            }
            .prominentButtonStyle()
        }
    }
}

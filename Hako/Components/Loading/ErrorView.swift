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
        ZStack {
            Spacer().containerRelativeFrame([.horizontal, .vertical])
            VStack {
                Text("Unable to load")
                Button("Try again") {
                    Task {
                        await refresh()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

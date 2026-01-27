//
//  ErrorView.swift
//  Hako
//
//  Created by Gao Tianrun on 12/5/25.
//

import SwiftUI

struct ErrorView: View {
    @Environment(\.screenSize) private var screenSize
    private let refresh: () async -> Void

    init(refresh: @escaping () async -> Void) {
        self.refresh = refresh
    }
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .frame(width: 40, height: 40)
                .padding(.bottom, 5)
            Text("Unable to load")
                .bold()
                .padding(.bottom, 5)
            Button("Try again") {
                Task {
                    await refresh()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

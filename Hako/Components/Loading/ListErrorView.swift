//
//  ListErrorView.swift
//  Hako
//
//  Created by Gao Tianrun on 15/9/25.
//

import SwiftUI

struct ListErrorView: View {
    private let refresh: () async -> Void

    init(refresh: @escaping () async -> Void) {
        self.refresh = refresh
    }
    
    var body: some View {
        VStack {
            Text("Unable to load")
            Button("Try again") {
                Task {
                    await refresh()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 50)
    }
}

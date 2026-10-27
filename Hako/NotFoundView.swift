//
//  NotFoundView.swift
//  Hako
//
//  Created by Gao Tianrun on 25/10/26.
//

import SwiftUI

struct NotFoundView: View {
    @Environment(Router.self) private var router

    var body: some View {
        ContentUnavailableView {
            Label("Not Found", systemImage: "exclamationmark.triangle")
        } description: {
            Text("Page does not exist")
        } actions: {
            Button("Go Back") {
                router.pop()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

//
//  LoadingView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            ProgressView {
                Text("Loading")
                    .font(.system(size: 17))
                    .foregroundColor(.white)
            }
            .tint(.white)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 130, height: 100)
                    .foregroundStyle(.thickMaterial)
                    .environment(\.colorScheme, .dark)
            }
        }
    }
}

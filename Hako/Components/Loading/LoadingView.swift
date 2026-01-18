//
//  LoadingView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

struct LoadingView: View {
    @ScaledMetric private var width = 130
    @ScaledMetric private var height = 100
    
    var body: some View {
        ZStack {
            ProgressView {
                Text("Loading")
                    .foregroundColor(.white)
            }
            .tint(.white)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: width, height: height)
                    .foregroundStyle(.thickMaterial)
                    .environment(\.colorScheme, .dark)
            }
        }
    }
}

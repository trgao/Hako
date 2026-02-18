//
//  LoadingView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

struct LoadingView: View {
    @ScaledMetric private var size = 60
    
    var body: some View {
        ZStack {
            ProgressView()
            .tint(.white)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: size, height: size)
                    .foregroundStyle(.thickMaterial)
                    .environment(\.colorScheme, .dark)
            }
        }
    }
}

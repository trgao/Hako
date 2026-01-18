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
                    .foregroundColor(Color(hex: 0x2e2e2e))
            }
        }
    }
}

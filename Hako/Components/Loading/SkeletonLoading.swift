//
//  SkeletonLoading.swift
//  Hako
//
//  Created by Gao Tianrun on 7/1/26.
//

import SwiftUI
import Shimmer

extension View {
    func skeleton() -> some View {
        return self.redacted(reason: .placeholder).shimmering()
    }
}

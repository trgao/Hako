//
//  ThickProgressViewStyle.swift
//  Hako
//
//  Created by Gao Tianrun on 7/11/26.
//

import SwiftUI

struct ThickProgressViewStyle: ProgressViewStyle {
  func makeBody(configuration: Configuration) -> some View {
      ProgressView(configuration)
          .frame(height: 6)
          .scaleEffect(x: 1, y: 2, anchor: .center)
          .clipShape(RoundedRectangle(cornerRadius: 10))
  }
}

extension ProgressViewStyle where Self == ThickProgressViewStyle {
    static var thick: Self {
        .init()
    }
}

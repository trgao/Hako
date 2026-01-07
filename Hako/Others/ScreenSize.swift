//
//  ScreenSize.swift
//  Hako
//
//  Created by Gao Tianrun on 7/1/26.
//

import SwiftUI

private struct ScreenSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = .zero
}

extension EnvironmentValues {
    var screenSize: CGSize {
        get { self[ScreenSizeKey.self] }
        set { self[ScreenSizeKey.self] = newValue }
    }
}

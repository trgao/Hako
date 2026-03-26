//
//  ProminentButtonStyle.swift
//  Hako
//
//  Created by Gao Tianrun on 26/3/26.
//

import SwiftUI


struct ProminentButtonStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.buttonStyle(.glassProminent)
        } else {
            content.buttonStyle(.borderedProminent)
        }
    }
}

extension View {
    func prominentButtonStyle() -> some View {
        modifier(ProminentButtonStyleModifier())
    }
}

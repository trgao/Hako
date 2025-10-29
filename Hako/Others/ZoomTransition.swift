//
//  ZoomTransition.swift
//  Hako
//
//  Created by Gao Tianrun on 14/5/25.
//

import SwiftUI

struct ZoomTransition<Content: View, Label: View>: View {
    @Namespace private var namespace
    private let content: () -> Content
    private let label: () -> Label
    
    init(content: @escaping () -> Content, label: @escaping () -> Label) {
        self.content = content
        self.label = label
    }
    
    var body: some View {
        NavigationLink {
            if #available(iOS 18.0, *) {
                content()
                    .navigationTransition(.zoom(sourceID: "item", in: namespace))
            } else {
                content()
            }
        } label: {
            if #available(iOS 18.0, *) {
                label()
                    .matchedTransitionSource(id: "item", in: namespace)
//                    .tint(.primary)
                    .multilineTextAlignment(.leading)
            } else {
                label()
//                    .tint(.primary)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

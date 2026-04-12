//
//  SkeletonLoading.swift
//  Hako
//
//  Created by Gao Tianrun on 7/1/26.
//

import SwiftUI

extension View {
    func skeleton(_ active: Bool = true) -> some View {
        return self
            .redacted(reason: .placeholder)
            .modifier(ShimmerEffect(active: active))
    }
}

struct ShimmerEffect: ViewModifier {
    @State var startPoint: UnitPoint = .init(x: -1, y: 0.5)
    @State var endPoint: UnitPoint = .init(x: 0, y: 0.5)
    private let gradientColors: [Color] = [
        .primary.opacity(0.8),
        .primary.opacity(0.9),
        .primary,
        .primary.opacity(0.9),
        .primary.opacity(0.8)
    ]
    private let animation: Animation = .easeInOut(duration: 1.3).repeatForever(autoreverses: true)
    private let active: Bool
    
    init(active: Bool) {
        self.active = active
    }
    
    private func updateAnimation() {
        if active {
            withAnimation(animation) {
                startPoint = .init(x: 1, y: 0.5)
                endPoint = .init(x: 2, y: 0.5)
            }
        } else {
            // Disable animation from continuing forever
            var transaction = Transaction()
            transaction.disablesAnimations = true

            withTransaction(transaction) {
                startPoint = .init(x: -1, y: 0.5)
                endPoint = .init(x: 0, y: 0.5)
            }
        }
    }
    
    func body(content: Content) -> some View {
        content.mask {
            LinearGradient(colors: gradientColors, startPoint: startPoint, endPoint: endPoint)
                .onAppear {
                    updateAnimation()
                }
                .onChange(of: active) {
                    updateAnimation()
                }
        }
    }
}

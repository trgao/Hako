//
//  ScrollViewSection.swift
//  Hako
//
//  Created by Gao Tianrun on 20/6/25.
//

import SwiftUI

struct ScrollViewSection<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    private let title: String
    private let content: () -> Content
    
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 15)
                .font(.system(size: 17))
            VStack(spacing: 0) {
                Divided {
                    content()
                }
            }
            .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal, 17)
    }
}

struct Divided<Content: View>: View {
    private let hasIcon: Bool
    private let content: Content

    init(hasIcon: Bool = false, @ViewBuilder content: () -> Content) {
        self.hasIcon = hasIcon
        self.content = content()
    }

    var body: some View {
        _VariadicView.Tree(DividedLayout()) {
            content
        }
    }

    struct DividedLayout: _VariadicView_MultiViewRoot {
        @ViewBuilder
        func body(children: _VariadicView.Children) -> some View {
            let last = children.last?.id

            ForEach(children) { child in
                child

                if child.id != last {
                    HStack(spacing: 0) {
                        Rectangle()
                            .frame(width: 20, height: 0.33)
                            .foregroundStyle(.clear)
                        Rectangle()
                            .fill(Color.gray)
                            .opacity(0.4)
                            .frame(height: 0.33)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}


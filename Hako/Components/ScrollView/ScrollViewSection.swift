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
    
    init(title: String = "", @ViewBuilder content: @escaping () -> Content) {
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
                content()
            }
            .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal, 17)
    }
}

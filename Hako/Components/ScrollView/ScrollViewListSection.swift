//
//  ScrollViewListSection.swift
//  Hako
//
//  Created by Gao Tianrun on 18/9/25.
//

import SwiftUI

struct ScrollViewListSection<Content: View>: View {
    @State private var isExpanded = true
    private let title: String
    private let content: () -> Content
    
    init(title: String = "", @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Button{
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(title)
                    Image(systemName: "chevron.right")
                        .rotationEffect(Angle(degrees: isExpanded ? 90 : 0))
                        .foregroundStyle(Color(.systemGray2))
                        .frame(width: 30, height: 30)
                }
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.top, 10)
            if isExpanded {
                LazyVStack(spacing: 5) {
                    content()
                }
            }
        }
        .padding(.horizontal, 17)
        .padding(.bottom, 5)
    }
}

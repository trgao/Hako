//
//  ScrollViewListSection.swift
//  Hako
//
//  Created by Gao Tianrun on 18/9/25.
//

import SwiftUI

struct ScrollViewListSection<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isExpanded = true
    private let title: String
    private let content: () -> Content
    private let isExpandable: Bool
    
    init(title: String = "", isExpandable: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.isExpandable = isExpandable
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                if isExpandable {
                    Button{
                        withAnimation {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .rotationEffect(Angle(degrees: isExpanded ? 90 : 0))
                            .foregroundStyle(Color(.systemGray2))
                    }
                }
            }
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .font(.headline)
            if !isExpandable || isExpanded {
                LazyVStack(spacing: 5) {
                    content()
                }
            }
        }
        .padding(.horizontal, 17)
        .padding(.bottom, 5)
    }
}

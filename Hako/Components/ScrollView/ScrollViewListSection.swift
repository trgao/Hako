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
                    .bold()
                Spacer()
                if isExpandable {
                    Button{
                        withAnimation {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .rotationEffect(!isExpanded ? Angle(degrees: 0) : Angle(degrees: 90))
                            .foregroundStyle(Color(.systemGray2))
                    }
                    .frame(width: 10, height: 10)
                }
            }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .font(.system(size: 17))
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

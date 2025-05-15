//
//  ListViewLink.swift
//  MALC
//
//  Created by Gao Tianrun on 15/5/25.
//

import SwiftUI

struct ListViewLink<Link:View, T>: View {
    private let title: String
    private let items: [T]
    private let link: () -> Link
    
    init(title: String, items: [T], link: @escaping () -> Link) {
        self.title = title
        self.items = items
        self.link = link
    }
    
    var body: some View {
        if items.count > 10 {
            NavigationLink {
                link()
            } label: {
                HStack {
                    Text(title)
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color(.systemGray2))
                }
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 35)
                .font(.system(size: 17))
            }
            .buttonStyle(.plain)
        } else {
            Text(title)
                .bold()
                .font(.system(size: 17))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 35)
        }
    }
}


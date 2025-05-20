//
//  ListRow.swift
//  Hako
//
//  Created by Gao Tianrun on 13/5/25.
//

import SwiftUI

struct ListRow<T>: View {
    private let title: String
    private let content: T?
    private let icon: String?
    private let color: Color?
    
    init(title: String, content: T?, icon: String? = nil, color: Color? = nil) {
        self.title = title
        self.content = content
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        HStack {
            if let icon = icon, let color = color {
                Label {
                    Text(title)
                        .bold()
                } icon: {
                    Image(systemName: icon)
                        .foregroundColor(color)
                }
            } else if let icon = icon {
                Label(title, systemImage: icon)
            } else {
                Text(title)
                    .bold()
            }
            Spacer()
            LoadingText(content: content)
        }
    }
}

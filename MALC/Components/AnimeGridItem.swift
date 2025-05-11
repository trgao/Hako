//
//  AnimeGridItem.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//  Cannot directly use MALListItem as JikanListItem also uses this
//

import SwiftUI

struct AnimeGridItem: View {
    private let id: Int
    private let title: String?
    private let subtitle: String?
    
    init(id: Int, title: String?, subtitle: String? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        NavigationLink {
            AnimeDetailsView(id: id)
        } label: {
            VStack {
                ImageFrame(id: "anime\(id)", width: 150, height: 212)
                    .overlay {
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .bold()
                                .font(.system(size: 16))
                                .foregroundStyle(.white)
                                .padding(10)
                                .background {
                                    Color(hex: 0x000000, opacity: 0.6)
                                        .blur(radius: 8, opaque: false)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        }
                    }
                Text(title ?? "")
                    .frame(width: 150, alignment: .leading)
                    .padding(5)
                    .font(.system(size: 16))
            }
        }
        .buttonStyle(.plain)
        .padding(5)
    }
}

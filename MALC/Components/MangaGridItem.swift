//
//  MangaGridItem.swift
//  MALC
//
//  Created by Gao Tianrun on 11/5/25.
//  Cannot directly use MALListItem as JikanListItem also uses this
//

import SwiftUI

struct MangaGridItem: View {
    private let id: Int
    private let title: String?
    private let imageUrl: String?
    private let subtitle: String?
    
    init(id: Int, title: String?, imageUrl: String?, subtitle: String? = nil) {
        self.id = id
        self.title = title
        self.imageUrl = imageUrl
        self.subtitle = subtitle
    }
    
    var body: some View {
        NavigationLink {
            MangaDetailsView(id: id, imageUrl: imageUrl)
        } label: {
            VStack {
                ImageFrame(id: "manga\(id)", imageUrl: imageUrl, imageSize: .large)
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


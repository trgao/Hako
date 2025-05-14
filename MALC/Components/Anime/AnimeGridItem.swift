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
    private let imageUrl: String?
    private let subtitle: String?
    
    init(id: Int, title: String?, imageUrl: String?, subtitle: String? = nil) {
        self.id = id
        self.title = title
        self.imageUrl = imageUrl
        self.subtitle = subtitle
    }
    
    var body: some View {
        ZoomTransition {
            AnimeDetailsView(id: id, imageUrl: imageUrl)
        } label: {
            VStack {
                ImageFrame(id: "anime\(id)", imageUrl: imageUrl, imageSize: .large)
                    .overlay {
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .bold()
                                .font(.system(size: 16))
                                .foregroundStyle(.white)
                                .padding(10)
                                .background {
                                    Color.black.opacity(0.4)
                                        .blur(radius: 8, opaque: false)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                Text(title ?? "")
                    .frame(width: 150, alignment: .leading)
                    .padding(5)
                    .font(.system(size: 16))
            }
        }
        .padding(5)
    }
}

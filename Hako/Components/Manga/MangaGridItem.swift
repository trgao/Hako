//
//  MangaGridItem.swift
//  Hako
//
//  Created by Gao Tianrun on 11/5/25.
//  Cannot directly use MALListItem as JikanListItem also uses this
//

import SwiftUI

struct MangaGridItem: View {
    @EnvironmentObject private var settings: SettingsManager
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
            MangaDetailsView(id: id)
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
                                    Color.black.opacity(0.4)
                                        .blur(radius: 8, opaque: false)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                Text(title ?? "")
                    .lineLimit(settings.getLineLimit())
                    .frame(width: 150, alignment: .leading)
                    .padding(5)
                    .font(.system(size: 16))
            }
        }
        .padding(5)
    }
}


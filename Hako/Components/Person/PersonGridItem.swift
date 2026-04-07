//
//  PersonGridItem.swift
//  Hako
//
//  Created by Gao Tianrun on 24/10/24.
//

import SwiftUI

struct PersonGridItem: View {
    @Environment(\.screenRatio) private var screenRatio
    @EnvironmentObject private var settings: SettingsManager
    private let id: Int
    private let name: String?
    private let imageUrl: String?
    private let subtitle: String?
    
    init(id: Int, name: String?, imageUrl: String?, subtitle: String? = nil) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.subtitle = subtitle
    }
    
    var body: some View {
        ZoomTransition {
            PersonDetailsView(id: id, name: name, imageUrl: imageUrl)
        } label: {
            VStack {
                ImageFrame(id: "person\(id)", imageUrl: imageUrl, imageSize: .medium)
                    .overlay {
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .bold()
                                .font(.subheadline)
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
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                    .contextMenu {
                        ShareLink(item: URL(string: "https://myanimelist.net/people/\(id)")!) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }
                Text(name ?? "")
                    .lineLimit(settings.getLineLimit())
                    .font(.footnote)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
            .frame(width: 110 * screenRatio)
        }
    }
}

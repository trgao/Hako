//
//  ImageFrame.swift
//  Hako
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

enum ImageSize {
    case reviewUser, small, medium, large, background
}

struct ImageFrame: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller: ImageFrameController
    private var fullscreen = false
    private let width: CGFloat
    private let height: CGFloat
    let networker = NetworkManager.shared
    
    init(id: String, imageUrl: String?, imageSize: ImageSize) {
        self._controller = StateObject(wrappedValue: ImageFrameController(id: id, imageUrl: imageUrl))
        if imageSize == .reviewUser {
            self.width = 30
            self.height = 30
        } else if imageSize == .small {
            self.width = 75
            self.height = 106
        } else if imageSize == .medium {
            self.width = 100
            self.height = 142
        } else if imageSize == .large {
            self.width = 150
            self.height = 213
        } else {
            self.fullscreen = true
            self.width = 0
            self.height = 0
        }
    }
    
    var body: some View {
        if fullscreen {
            if let image = controller.image, settings.translucentBackground {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay {
                        Rectangle()
                            .foregroundStyle(.thickMaterial)
                            .padding(-500)
                    }
            } else {
                Rectangle()
                    .foregroundStyle(colorScheme == .light ? Color(.systemGray6) : Color(.systemBackground))
                    .frame(width: width, height: height)
            }
        } else {
            VStack {
                if let image = controller.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.gray)
                }
            }
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

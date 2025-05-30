//
//  ImageFrame.swift
//  Hako
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

enum ImageSize {
    case small, medium, large, background
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
        if imageSize == .small {
            self.width = 75
            self.height = 106
        } else if imageSize == .medium {
            self.width = 100
            self.height = 141
        } else if imageSize == .large {
            self.width = 150
            self.height = 212
        } else {
            self.fullscreen = true
            self.width = UIScreen.main.bounds.width
            self.height = UIScreen.main.bounds.height + 70
        }
    }
    
    var body: some View {
        if fullscreen {
            if let data = controller.image, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
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
        } else if let data = controller.image, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 2)
        } else {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.gray)
                .frame(width: width, height: height)
                .shadow(radius: 2)
        }
    }
}

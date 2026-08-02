//
//  ImageFrame.swift
//  Hako
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

struct ImageFrame: View {
    @Environment(\.screenRatio) private var screenRatio
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller: ImageFrameController
    private let imageUrl: String?
    private let imageSize: ImageSizeEnum
    private let networker = NetworkManager.shared
    private var width: CGFloat {
        switch imageSize {
        case .reviewUser: return 30
        case .small: return 75
        case .medium: return 100
        case .large: return 150
        case .episode: return 142
        case .background: return 100000
        }
    }
    private var height: CGFloat {
        switch imageSize {
        case .reviewUser: return 30
        case .small: return 106
        case .medium: return 142
        case .large: return 213
        case .episode: return 100
        case .background: return 100000
        }
    }
    
    init(id: String, imageUrl: String?, imageSize: ImageSizeEnum) {
        self._controller = StateObject(wrappedValue: ImageFrameController(id: id, imageUrl: imageUrl))
        self.imageUrl = imageUrl
        self.imageSize = imageSize
    }
    
    var body: some View {
        VStack {
            if imageSize == .background {
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
                        .foregroundStyle(colorScheme == .light ? Color(.systemGray6) : .black)
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
                            .opacity(0.6)
                    }
                }
                .frame(width: width * screenRatio, height: height * screenRatio)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .task(id: imageUrl) {
            controller.imageUrl = imageUrl
            await controller.refresh()
        }
    }
}

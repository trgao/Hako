//
//  ImageFrameController.swift
//  Hako
//
//  Created by Gao Tianrun on 11/11/24.
//

import SwiftUI
import Foundation

@MainActor
class ImageFrameController: ObservableObject {
    @Published var image: Data?
    private let isProfile: Bool
    let networker = NetworkManager.shared
    
    init(id: String, imageUrl: String?, isProfile: Bool = false) {
        self.isProfile = isProfile
        Task {
            self.image = await self.networker.downloadImage(id: id, imageUrl: imageUrl)
            if let image = self.image, isProfile {
                UserDefaults.standard.set(image, forKey: "userImage")
            }
        }
    }
}

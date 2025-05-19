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
            await self.networker.downloadImage(id: id, imageUrl: imageUrl)
            self.image = self.networker.getImage(id: id)
            if isProfile {
                UserDefaults.standard.set(self.image, forKey: "userImage")
            }
        }
    }
}

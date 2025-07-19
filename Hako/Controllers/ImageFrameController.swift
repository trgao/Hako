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
    @Published var image: UIImage?
    let networker = NetworkManager.shared
    
    init(id: String, imageUrl: String?, isProfile: Bool = false) {
        Task {
            let data = await self.networker.downloadImage(id: id, imageUrl: imageUrl)
            if let data = data {
                self.image = UIImage(data: data)
                if isProfile {
                    UserDefaults.standard.set(data, forKey: "userImage")
                }
            }
        }
    }
}

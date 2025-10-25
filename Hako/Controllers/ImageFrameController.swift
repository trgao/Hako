//
//  ImageFrameController.swift
//  Hako
//
//  Created by Gao Tianrun on 11/11/24.
//

import SwiftUI

@MainActor
class ImageFrameController: ObservableObject {
    @Published var image: UIImage?
    let networker = NetworkManager.shared
    
    init(id: String, imageUrl: String?, isProfile: Bool = false) {
        if let data = networker.getImage(id: id) {
            self.image = UIImage(data: data)
        } else {
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
}

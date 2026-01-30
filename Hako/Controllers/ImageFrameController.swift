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
    private let id: String
    private let imageUrl: String?
    private let isProfile: Bool
    private let networker = NetworkManager.shared
    
    init(id: String, imageUrl: String?, isProfile: Bool = false) {
        self.id = id
        self.imageUrl = imageUrl
        self.isProfile = isProfile
    }
    
    func refresh() async {
        guard image == nil else {
            return
        }
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

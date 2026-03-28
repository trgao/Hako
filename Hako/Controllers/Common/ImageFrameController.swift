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
    var imageUrl: String?
    private let isProfile: Bool
    private let networker = NetworkManager.shared
    
    init(id: String, imageUrl: String?, isProfile: Bool = false) {
        self.id = id
        self.imageUrl = imageUrl
        self.isProfile = isProfile
    }
    
    func refresh() async {
        guard let imageUrl = imageUrl, image == nil else {
            return
        }
        let data = await networker.downloadImage(id: id, imageUrl: imageUrl)
        if let data = data {
            self.image = UIImage(data: data)
            if isProfile {
                UserDefaults.standard.set(data, forKey: "userImage")
            }
        }
    }
}

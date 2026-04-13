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
        guard image == nil && (isProfile || imageUrl != nil) else {
            return
        }
        
        if isProfile, let data = await networker.downloadImage(id: id, imageUrl: imageUrl ?? "https://myanimelist.net/images/kaomoji_mal_white.png") {
            self.image = UIImage(data: data)
            UserDefaults.standard.set(data, forKey: "userImage")
        } else if let data = await networker.downloadImage(id: id, imageUrl: imageUrl) {
            self.image = UIImage(data: data)
        }
    }
}

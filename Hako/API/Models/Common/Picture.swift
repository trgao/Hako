//
//  Picture.swift
//  Hako
//
//  Created by Gao Tianrun on 12/7/25.
//

import Foundation

struct Picture: Codable {
    let medium: String?
    let large: String?
    
    init(medium: String?, large: String?) {
        self.medium = medium
        self.large = large
    }
    
    init(images: Images?) {
        self.medium = images?.jpg?.imageUrl
        self.large = images?.jpg?.largeImageUrl
    }
}

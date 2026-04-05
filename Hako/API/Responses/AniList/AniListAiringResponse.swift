//
//  AniListAiringResponse.swift
//  Hako
//
//  Created by Gao Tianrun on 15/6/25.
//

import Foundation

struct AniListAiringResponse: Codable {
    struct Data: Codable {
        struct Media: Codable {
            let nextAiringEpisode: NextAiringEpisode?
        }
        
        let Media: Media
    }
    
    let data: Data
}

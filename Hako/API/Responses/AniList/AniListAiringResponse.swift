//
//  AniListAiringResponse.swift
//  Hako
//
//  Created by Gao Tianrun on 15/6/25.
//

import Foundation

struct AniListAiringResponse: Codable {
    let data: AniListAiringData
}

struct AniListAiringData: Codable {
    let Media: Media
}

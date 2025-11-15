//
//  JikanListItem.swift
//  Hako
//
//  Created by Gao Tianrun on 11/5/24.
//

import Foundation

struct JikanListItem: Codable, Identifiable {
    var id: Int { malId }
    let malId: Int
    let title: String?
    let titleJapanese: String?
    let titleEnglish: String?
    let name: String?
    let images: Images?
    let score: Double?
    let rank: Int?
    let popularity: Int?
    let type: String?
    let status: String?
    let episodes: Int?
    let volumes: Int?
    let chapters: Int?
    let duration: String?
    let synopsis: String?
    let season: String?
    let year: Int?
    let source: String?
    let members: Int?
}

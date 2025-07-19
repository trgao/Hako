//
//  Node.swift
//  Hako
//
//  Created by Gao Tianrun on 6/5/24.
//

import Foundation

struct Node: Codable {
    let id: Int
    let title: String
    let mainPicture: MainPicture?
    let alternativeTitles: AlternativeTitles?
    let startSeason: Season?
    let numEpisodes: Int?
    let numVolumes: Int?
    let numChapters: Int?
    let status: String?
    let rating: String?
}

struct Ranking: Codable {
    let rank: Int?
}

//
//  Media.swift
//  Hako
//
//  Created by Gao Tianrun on 15/6/25.
//

struct Media: Codable {
    let nextAiringEpisode: NextAiringEpisode?
}

struct NextAiringEpisode: Codable {
    let airingAt: Int
    let episode: Int
}

//
//  Episode.swift
//  Hako
//
//  Created by Gao Tianrun on 7/7/26.
//

import Foundation

struct Episode: Codable, Identifiable, Hashable {
    var id: Int { malId }
    let malId: Int
    let title: String
    let titleJapanese: String?
    let titleRomanji: String?
    let aired: Date?
    let score: Double?
    let filler: Bool?
    let recap: Bool?
    let forumUrl: String?
    let replies: Int?
    let duration: Int?
    let synopsis: String?
    let url: String?
}

struct EpisodeList: Hashable {
    let id: Int
}

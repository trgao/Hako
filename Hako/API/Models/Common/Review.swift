//
//  Review.swift
//  Hako
//
//  Created by Gao Tianrun on 14/6/25.
//

import Foundation

struct Review: Codable, Identifiable, Hashable {
    var id: Int { malId }
    let malId: Int
    let url: String?
    let date: Date?
    let review: String?
    let tags: [String]?
    let user: ReviewUser?
    let score: Int?
}

struct ReviewUser: Codable, Hashable {
    let username: String?
    let images: Images?
}

struct ReviewList: Hashable {
    let id: Int
    let type: TypeEnum
}

//
//  Review.swift
//  Hako
//
//  Created by Gao Tianrun on 14/6/25.
//

import Foundation

struct Review: Codable, Identifiable {
    var id: Int { malId }
    let malId: Int
    let url: String?
    let date: Date?
    let review: String?
    let tags: [String]?
    let user: ReviewUser?
}

struct ReviewUser: Codable {
    let username: String?
    let images: Images?
}

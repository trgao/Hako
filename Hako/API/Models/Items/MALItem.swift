//
//  MALItem.swift
//  Hako
//
//  Created by Gao Tianrun on 11/5/24.
//

import Foundation

struct MALItem: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
}

struct Ranking: Codable, Hashable {
    let rank: Int?
}

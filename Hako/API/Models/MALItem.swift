//
//  MALItem.swift
//  Hako
//
//  Created by Gao Tianrun on 11/5/24.
//

import Foundation

struct MALItem: Codable, Identifiable {
    let id: Int
    let name: String
}

struct Ranking: Codable {
    let rank: Int?
}

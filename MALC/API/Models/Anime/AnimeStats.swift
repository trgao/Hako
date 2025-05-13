//
//  AnimeStats.swift
//  MALC
//
//  Created by Gao Tianrun on 13/5/25.
//

import Foundation

struct AnimeStats: Codable {
    let watching: Int
    let completed: Int
    let onHold: Int
    let dropped: Int
    let planToWatch: Int
    let total: Int
}

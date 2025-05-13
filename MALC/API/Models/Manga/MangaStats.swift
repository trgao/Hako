
//
//  MangaStats.swift
//  MALC
//
//  Created by Gao Tianrun on 13/5/25.
//

import Foundation

struct MangaStats: Codable {
    let reading: Int
    let completed: Int
    let onHold: Int
    let dropped: Int
    let planToRead: Int
    let total: Int
}

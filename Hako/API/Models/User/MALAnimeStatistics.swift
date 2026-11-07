//
//  MALAnimeStatistics.swift
//  Hako
//
//  Created by Gao Tianrun on 7/11/26.
//

import Foundation

struct MALAnimeStatistics: Codable, Hashable {
    let numDays: Float?
    let meanScore: Float?
    let numItemsWatching: Int?
    let numItemsCompleted: Int?
    let numItemsOnHold: Int?
    let numItemsDropped: Int?
    let numItemsPlanToWatch: Int?
    let numItems: Int?
    let numEpisodes: Int?
}

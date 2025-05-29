//
//  AnimeListStatus.swift
//  Hako
//
//  Created by Gao Tianrun on 11/5/24.
//

import Foundation

struct AnimeListStatus: Codable, Equatable {
    var status: StatusEnum?
    var score: Int
    var numEpisodesWatched: Int
    var startDate: Date?
    var finishDate: Date?
    let updatedAt: Date?
}
